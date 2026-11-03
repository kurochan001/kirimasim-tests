"""Atomic admission of additional exploration jobs, not an execution-result cache.

Completed receipts remain immutable. A newer failed/interrupted/invalid attempt
prevents falling back to an older success. Live owners are never lease-stolen.
"""

import hashlib
from contextlib import contextmanager
import json
import os
from pathlib import Path
import platform
import sqlite3
import subprocess
import time
import uuid

import random_cross_evidence as evidence


def host_id():
    return hashlib.sha256((platform.node()+'\0'+platform.system()).encode()).hexdigest()


def process_start(pid):
    try:
        result = subprocess.run(['ps', '-p', str(pid), '-o', 'lstart='], capture_output=True,
                                text=True, timeout=5, env={**os.environ, 'LC_ALL': 'C'})
        return result.stdout.strip() if result.returncode == 0 else ''
    except (OSError, subprocess.SubprocessError):
        return ''


def alive(row):
    if row['host'] != host_id():
        return True  # Another host's liveness is unknown; do not steal its work.
    try:
        os.kill(row['pid'], 0)
    except ProcessLookupError:
        return False
    except PermissionError:
        return True
    birth = process_start(row['pid'])
    return not birth or not row['birth'] or birth == row['birth']


class History:
    def __init__(self, path):
        self.path = Path(path).resolve()
        self.path.parent.mkdir(parents=True, exist_ok=True)
        with self.connect() as db:
            db.execute('''CREATE TABLE IF NOT EXISTS attempts (
                id TEXT PRIMARY KEY, job TEXT NOT NULL, host TEXT NOT NULL,
                pid INTEGER NOT NULL, birth TEXT NOT NULL, state TEXT NOT NULL,
                started REAL NOT NULL, finished REAL, output TEXT NOT NULL,
                eligible INTEGER NOT NULL DEFAULT 0, receipt TEXT)''')

    @contextmanager
    def connect(self):
        db = sqlite3.connect(self.path, timeout=30)
        db.row_factory = sqlite3.Row
        try:
            with db:
                yield db
        finally:
            db.close()

    def admit(self, job, output, force=False):
        with self.connect() as db:
            db.execute('BEGIN IMMEDIATE')
            running = list(db.execute("SELECT * FROM attempts WHERE job=? AND state='running'", (job,)))
            live = []
            for row in running:
                if alive(row):
                    live.append(row)
                else:
                    db.execute("UPDATE attempts SET state='interrupted', finished=?, eligible=0 WHERE id=?",
                               (time.time(), row['id']))
            if live and not force:
                return {'decision': 'in_flight', 'job': job, 'prior_attempt': live[-1]['id']}
            latest = db.execute('SELECT * FROM attempts WHERE job=? ORDER BY rowid DESC LIMIT 1', (job,)).fetchone()
            if not force and latest is not None and latest['eligible']:
                if evidence.reusable(Path(latest['output']), json.loads(latest['receipt']), job):
                    return {'decision': 'duplicate_completed', 'job': job,
                            'prior_attempt': latest['id'], 'prior_output': latest['output'],
                            'prior_report_sha256': evidence.sha(Path(latest['output'])/'run.json')}
                db.execute("UPDATE attempts SET state='invalid_receipt', eligible=0 WHERE id=?", (latest['id'],))
            attempt = uuid.uuid4().hex
            db.execute('INSERT INTO attempts(id,job,host,pid,birth,state,started,output) VALUES(?,?,?,?,?,?,?,?)',
                       (attempt, job, host_id(), os.getpid(), process_start(os.getpid()),
                        'running', time.time(), str(output.resolve())))
            return {'decision': 'forced' if force else 'execute', 'job': job, 'attempt': attempt}

    def finish(self, admission, output, report):
        if 'attempt' not in admission:
            return
        eligible = evidence.all_pass(report)
        files = evidence.receipt(output) if eligible else None
        with self.connect() as db:
            db.execute('UPDATE attempts SET state=?,finished=?,eligible=?,receipt=? WHERE id=? AND state=?',
                       ('completed' if report.get('completed') else 'interrupted', time.time(), int(eligible),
                        json.dumps(files) if files is not None else None, admission['attempt'], 'running'))

    def abort(self, admission):
        if 'attempt' in admission:
            with self.connect() as db:
                db.execute("UPDATE attempts SET state='interrupted',finished=?,eligible=0 WHERE id=? AND state='running'",
                           (time.time(), admission['attempt']))

"""The kirimasim ratchet: a test that matched before must not fail or become
unsupported; other changes do not fail it."""

import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parent / 'results_ratchet.py'


def ratchet(previous, current):
    with tempfile.TemporaryDirectory() as tmp:
        a, b = Path(tmp) / 'a.json', Path(tmp) / 'b.json'
        a.write_text(json.dumps({'tests': previous}))
        b.write_text(json.dumps({'tests': current}))
        r = subprocess.run([sys.executable, str(SCRIPT), str(a), str(b)], capture_output=True, text=True)
        return r.returncode, r.stdout


class Ratchet(unittest.TestCase):
    def test_pass_to_fail_and_pass_to_unsupported_are_regressions(self):
        code, out = ratchet({'a': 'pass', 'b': 'pass', 'c': 'pass'},
                            {'a': {'status': 'fail', 'reason': 'differs'},
                             'b': {'status': 'unsupported', 'reason': 'error: unsupported: x'},
                             'c': {'status': 'pass'}})
        self.assertEqual(code, 1)
        self.assertIn('REGRESSION a: fail: differs', out)
        self.assertIn('REGRESSION b: unsupported: error: unsupported: x', out)
        self.assertIn('2 of the 3 tests that matched before differ now', out)

    def test_known_new_gone_and_earlier_failures_do_not_count(self):
        code, out = ratchet({'a': 'pass', 'b': 'fail', 'c': 'unsupported', 'gone': 'pass'},
                            {'a': {'status': 'known'}, 'b': {'status': 'fail'},
                             'c': {'status': 'unsupported'}, 'new': {'status': 'fail'}})
        self.assertEqual(code, 0)
        self.assertNotIn('REGRESSION', out)


if __name__ == '__main__':
    unittest.main()

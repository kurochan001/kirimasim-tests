"""Exercise the actual parser checkout step without accessing private sources."""

import json
import os
from pathlib import Path
import stat
import subprocess
import tempfile
import textwrap
import unittest


ROOT = Path(__file__).resolve().parents[1]
CANARIES = ("fixture-owner/fixture-parser", "fixture-revision", "fixture-parser-dir",
            "fixture-parser-deploy-key", "fixture-derived-commit", "fixture-owner/fixture-simulator",
            "fixture-deploy-key")


class PrivateParserCheckoutTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        workflow = (ROOT / ".github/workflows/nightly.yml").read_text(encoding="utf-8")
        step = workflow.split("      - name: Check out its parser\n", 1)[1]
        step = step.split("\n      - ", 1)[0]
        cls.script = textwrap.dedent(step.split("        run: |\n", 1)[1])

    def run_checkout(self, *, failures=0, error="unclassified", init_failure=False,
                     checkout_failure=False, path=CANARIES[2], ref=CANARIES[1], script=None,
                     parser_key=CANARIES[3]):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            executable = root / "bin"
            executable.mkdir()
            runner_temp = root / "runner"
            runner_temp.mkdir()
            workflow = root / ".github/workflows/nightly.yml"
            workflow.parent.mkdir(parents=True)
            workflow.write_text((ROOT / ".github/workflows/nightly.yml").read_text(encoding="utf-8"),
                                encoding="utf-8")
            fake_git = executable / "git"
            fake_git.write_text(textwrap.dedent('''\
                #!/usr/bin/env python3
                import json
                import os
                from pathlib import Path
                import shlex
                import stat
                import sys

                args = sys.argv[1:]
                state = Path(os.environ["FIXTURE_STATE"])
                with (state / "calls").open("a") as stream:
                    stream.write(json.dumps(args) + "\\n")
                operation = args[2] if args[0] == "-C" else args[0]
                private = " ".join(os.environ[name] for name in
                                   ("PARSER_REPOSITORY", "PARSER_REF", "PARSER_PATH", "PARSER_KEY",
                                    "PRIVATE_REPOSITORY", "PRIVATE_KEY"))
                print(private + " fixture-derived-commit")
                print(private + " fixture-derived-commit", file=sys.stderr)
                if operation == "clone":
                    Path(args[-1]).mkdir(parents=True)
                elif operation == "init":
                    if os.environ["FIXTURE_INIT_FAILURE"] == "1":
                        sys.exit(128)
                    Path(args[-1]).mkdir(parents=True)
                elif operation == "fetch":
                    ssh = shlex.split(os.environ["GIT_SSH_COMMAND"])
                    key = Path(ssh[ssh.index("-i") + 1])
                    assert key.read_text().strip() == os.environ["PARSER_KEY"]
                    assert stat.S_IMODE(key.stat().st_mode) == 0o600
                    for option in ("BatchMode=yes", "IdentitiesOnly=yes", "StrictHostKeyChecking=yes"):
                        assert option in ssh
                    assert args[-2] == "git@github.com:" + os.environ["PARSER_REPOSITORY"] + ".git"
                    counter = state / "fetches"
                    count = int(counter.read_text()) + 1 if counter.exists() else 1
                    counter.write_text(str(count))
                    if count <= int(os.environ["FIXTURE_FAILURES"]):
                        print(os.environ["FIXTURE_ERROR"], file=sys.stderr)
                        sys.exit(128)
                elif operation == "checkout":
                    if os.environ["FIXTURE_CHECKOUT_FAILURE"] == "1":
                        sys.exit(128)
                else:
                    sys.exit(99)
                '''), encoding="utf-8")
            fake_git.chmod(0o755)
            fake_sleep = executable / "sleep"
            fake_sleep.write_text('#!/bin/sh\nprintf "%s\\n" "$1" >> "$FIXTURE_STATE/sleeps"\n',
                                  encoding="utf-8")
            fake_sleep.chmod(0o755)
            environment = dict(os.environ, PATH=str(executable) + os.pathsep + os.environ["PATH"],
                               RUNNER_TEMP=str(runner_temp), PARSER_REPOSITORY=CANARIES[0],
                               PARSER_REF=ref, PARSER_PATH=path, PARSER_KEY=parser_key,
                               PRIVATE_REPOSITORY=CANARIES[5], PRIVATE_KEY=CANARIES[6],
                               FIXTURE_STATE=str(root), FIXTURE_FAILURES=str(failures),
                               FIXTURE_ERROR=error, FIXTURE_INIT_FAILURE=str(int(init_failure)),
                               FIXTURE_CHECKOUT_FAILURE=str(int(checkout_failure)))
            process = subprocess.run(["bash", "--noprofile", "--norc", "-eo", "pipefail", "-c",
                                      self.script if script is None else script], cwd=root, env=environment,
                                     capture_output=True, text=True, timeout=10)
            public = process.stdout + process.stderr
            for canary in CANARIES:
                self.assertNotIn(canary, public)
            self.assertNotIn(str(root), public)
            calls_file = root / "calls"
            calls = [json.loads(line) for line in calls_file.read_text().splitlines()] \
                if calls_file.exists() else []
            sleeps_file = root / "sleeps"
            sleeps = sleeps_file.read_text().splitlines() if sleeps_file.exists() else []
            raw = runner_temp / "ghost-parser-checkout.log"
            self.assertFalse((runner_temp / "ghost-parser-deploy-key").exists())
            if raw.exists():
                self.assertEqual(stat.S_IMODE(raw.stat().st_mode), 0o600)
                self.assertIn(CANARIES[4], raw.read_text())
            return process.returncode, public, calls, sleeps

    def test_success_checks_out_only_the_fetched_revision(self):
        code, output, calls, sleeps = self.run_checkout()
        self.assertEqual(code, 0)
        self.assertEqual(output, "")
        self.assertEqual(calls[-1][-3:], ["-q", "--detach", "FETCH_HEAD"])
        self.assertEqual(calls[1][-1], CANARIES[1])
        self.assertEqual(sleeps, [])

    def test_two_fetch_failures_recover_on_third_attempt(self):
        code, output, calls, sleeps = self.run_checkout(failures=2, error="Connection reset")
        self.assertEqual(code, 0)
        self.assertEqual(output.count("::warning::"), 2)
        self.assertNotIn("::error::", output)
        self.assertEqual(sum("fetch" in call for call in calls), 3)
        self.assertIn("checkout", calls[-1])
        self.assertEqual(sleeps, ["5", "10"])

    def test_exhausted_fetches_fail_with_only_a_safe_category(self):
        cases = (("fatal: couldn't find remote ref fixture-revision", "requested revision unavailable"),
                 ("fatal: Authentication failed", "authentication or repository access"),
                 ("fatal: repository not found", "authentication or repository access"),
                 ("fatal: Could not resolve host", "network or remote service"),
                 ("fatal: The requested URL returned error: 503", "network or remote service"),
                 ("unexpected fixture error", "unclassified failure"))
        for error, category in cases:
            with self.subTest(category=category, error=error):
                code, output, calls, sleeps = self.run_checkout(failures=9, error=error)
                self.assertNotEqual(code, 0)
                self.assertIn("after 3 attempts (" + category + ")", output)
                self.assertEqual(sum("fetch" in call for call in calls), 3)
                self.assertFalse(any("checkout" in call for call in calls))
                self.assertEqual(sleeps, ["5", "10"])

    def test_setup_failure_never_fetches(self):
        code, output, calls, sleeps = self.run_checkout(init_failure=True)
        self.assertNotEqual(code, 0)
        self.assertIn("directory could not be prepared", output)
        self.assertFalse(any("fetch" in call for call in calls))
        self.assertEqual(sleeps, [])

    def test_checkout_failure_does_not_become_success(self):
        code, output, calls, sleeps = self.run_checkout(checkout_failure=True)
        self.assertNotEqual(code, 0)
        self.assertIn("fetched parser could not be checked out", output)
        self.assertEqual(sum("fetch" in call for call in calls), 1)
        self.assertEqual(sleeps, [])

    def test_invalid_paths_are_rejected_before_any_git_operation(self):
        for path in ("", ".", "/fixture-parser-dir", "..", "../fixture-parser-dir",
                     "fixture-parser-dir/..", "fixture-parser-dir/../other"):
            with self.subTest(path=path):
                code, output, calls, sleeps = self.run_checkout(path=path)
                self.assertNotEqual(code, 0)
                self.assertIn("not a directory inside the workspace", output)
                self.assertEqual(calls, [])
                self.assertEqual(sleeps, [])

    def test_empty_ref_fetches_remote_head(self):
        code, _, calls, _ = self.run_checkout(ref="")
        self.assertEqual(code, 0)
        self.assertEqual(calls[1][-1], "HEAD")

    def test_diagnostic_executes_the_same_checkouts_and_preserves_fetch_failure(self):
        workflow = (ROOT / ".github/workflows/parser-checkout.yml").read_text(encoding="utf-8")
        script = textwrap.dedent(workflow.split("        run: |\n", 1)[1])
        for failures, expected_status in ((2, 0), (9, 1)):
            with self.subTest(failures=failures):
                code, output, calls, sleeps = self.run_checkout(
                    script=script, failures=failures, error="Connection reset")
                self.assertEqual(code, expected_status)
                self.assertEqual(calls[0][0], "clone")
                self.assertEqual(sum("fetch" in call for call in calls), 3)
                self.assertEqual(any("checkout" in call for call in calls), failures == 2)
                self.assertEqual(sleeps, ["5", "10"])
                self.assertEqual("::error::" in output, failures == 9)

    def test_missing_parser_key_stops_before_any_git_operation(self):
        code, output, calls, sleeps = self.run_checkout(parser_key="")
        self.assertNotEqual(code, 0)
        self.assertIn("parser read-only deploy key is not configured", output)
        self.assertEqual(calls, [])
        self.assertEqual(sleeps, [])


if __name__ == "__main__":
    unittest.main()

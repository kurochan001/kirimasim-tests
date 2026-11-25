"""Exercise the semantic stacktrace output checker."""

import subprocess
import unittest
from unittest.mock import patch

import run_stacktrace as stacktrace
import suite_results


def trace(*names):
    body = [f"  #{index} {name}" for index, name in enumerate(names)] or ["  (top level)"]
    return "\n".join(["=== Call Stack Trace ===", *body, "======================="])


def fence(marker, body=""):
    return f"{marker}_BEGIN\n{body}\n{marker}_END"


def run(case, stdout, returncode=0, stderr=""):
    fixture = suite_results.ROOT / "tests" / (case + ".sv")
    with patch.object(stacktrace.subprocess, "run",
                      return_value=subprocess.CompletedProcess([], returncode, stdout, stderr)):
        return stacktrace.run(fixture, fixture, case)


class StacktraceCheckerTests(unittest.TestCase):
    def test_result_requires_silent_capture_and_a_displayed_trace(self):
        expected_frame = trace("test_stacktrace_task_and_function_results.inspect_result")
        common = ["type=string nonempty=1", fence("RETURN", expected_frame)]
        for captured, shown, expected in (
            ("", expected_frame, "pass"),
            (expected_frame, expected_frame, "fail"),
            ("", "", "fail"),
        ):
            with self.subTest(captured=bool(captured), shown=bool(shown)):
                output = "\n".join([fence("CAPTURE", captured), *common, fence("TASK", shown)])
                self.assertEqual(run(stacktrace.RESULT, output)[0][0], expected)

    def test_context_distinguishes_missing_or_reordered_callers(self):
        initial = fence("INITIAL", trace("inner_task", "outer_task"))
        after = fence("AFTER", trace())
        for active, expected in (
            (("capture_context", "inner_task", "outer_task"), "pass"),
            (("capture_context",), "fail"),
            (("capture_context", "outer_task", "inner_task"), "fail"),
        ):
            with self.subTest(frames=active):
                output = "\n".join([initial, fence("RESUME", trace(*active)), after])
                self.assertEqual(run(stacktrace.CONTEXT, output)[0][0], expected)

    def test_correct_trace_cannot_mask_simulation_failure(self):
        output = "\n".join([
            fence("INITIAL", trace("inner_task", "outer_task")),
            fence("RESUME", trace("capture_context", "inner_task", "outer_task")),
            fence("AFTER", trace()),
        ])
        self.assertEqual(run(stacktrace.CONTEXT, output, returncode=-9)[0][0], "fail")
        self.assertEqual(run(stacktrace.CONTEXT, output, stderr="[ERROR] failed")[0][0], "fail")
        self.assertEqual(run(stacktrace.CONTEXT, output, stderr="[WARNING] optional")[0][0], "pass")

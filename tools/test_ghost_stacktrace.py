"""Check Ghost's stack frames around a suspended and resumed task."""

import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest


TRACE_SOURCE = """\
`timescale 1ns/1ns
module trace_probe;
  function automatic string capture_leaf();
    return $stacktrace;
  endfunction

  function automatic string capture_middle();
    return capture_leaf();
  endfunction

  task automatic child_task();
    $display("TASK_SYNC_BEGIN");
    $stacktrace;
    $display("TASK_SYNC_END");
    #2;
    $display("TASK_RESUME_BEGIN");
    $stacktrace;
    $display("TASK_RESUME_END");
  endtask

  task automatic outer_task();
    child_task();
  endtask

  initial begin : traced_root
    string trace;
    trace = capture_middle();
    $display("FUNCTION_BEGIN\\n%s\\nFUNCTION_END", trace);
    outer_task();
    $display("AFTER_BEGIN");
    $stacktrace;
    $display("AFTER_END");
  end
endmodule
"""


@unittest.skipUnless(os.environ.get("GHOST_SIMULATOR"), "set GHOST_SIMULATOR to run Ghost")
class GhostStacktrace(unittest.TestCase):
    def test_task_frames_survive_suspension_and_unwind_after_return(self):
        simulator = Path(os.environ["GHOST_SIMULATOR"]).resolve()
        with tempfile.TemporaryDirectory() as temporary:
            source = Path(temporary) / "trace_probe.sv"
            source.write_text(TRACE_SOURCE, encoding="utf-8")
            result = subprocess.run(
                [str(simulator), "--quiet-all", "--lrm-strict", source.name],
                cwd=temporary, capture_output=True, text=True, timeout=60,
            )
        self.assertEqual(result.returncode, 0, result.stderr or result.stdout)

        for context, expected in (
            ("FUNCTION", ["capture_leaf", "capture_middle"]),
            ("TASK_SYNC", ["child_task", "outer_task"]),
            ("TASK_RESUME", ["child_task", "outer_task"]),
            ("AFTER", []),
        ):
            with self.subTest(context=context):
                segment = re.search(fr"(?s){context}_BEGIN\n(.*?){context}_END", result.stdout)
                self.assertIsNotNone(segment, result.stdout)
                frames = re.findall(r"(?m)^\s*#\d+\s+([\w$.]+)", segment[1])
                self.assertEqual([name.rsplit(".", 1)[-1] for name in frames],
                                 expected, segment[1])

"""Check Ghost's stack frame identities across class calls and forked tasks."""

import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest


SOURCE = """\
`timescale 1ns/1ns
module mixed_trace_contexts;
  function automatic string capture_leaf();
    return $stacktrace;
  endfunction

  class bridge;
    function string capture_middle();
      return capture_leaf();
    endfunction
  endclass

  task automatic class_outer();
    bridge object_ref;
    object_ref = new;
    $display("CLASS_BEGIN\\n%s\\nCLASS_END", object_ref.capture_middle());
  endtask

  task automatic alpha();
    #2;
    $display("ALPHA_BEGIN\\n%s\\nALPHA_END", capture_leaf());
    #3;
    $display("ALPHA2_BEGIN\\n%s\\nALPHA2_END", capture_leaf());
  endtask

  task automatic beta();
    #3;
    $display("BETA_BEGIN\\n%s\\nBETA_END", capture_leaf());
    #3;
    $display("BETA2_BEGIN\\n%s\\nBETA2_END", capture_leaf());
  endtask

  initial begin
    class_outer();
    fork
      alpha();
      beta();
    join
    $display("AFTER_BEGIN\\n%s\\nAFTER_END", capture_leaf());
    $finish(0);
  end
endmodule
"""


@unittest.skipUnless(os.environ.get("GHOST_SIMULATOR"), "set GHOST_SIMULATOR to run Ghost")
class GhostStacktraceContexts(unittest.TestCase):
    def capture_frames(self, output: str, context: str) -> list[str]:
        section = re.search(fr"(?s){context}_BEGIN\n(.*?){context}_END", output)
        self.assertIsNotNone(section, output)
        frames = re.findall(r"(?m)^\s*#\d+\s+([\w$.:]+)", section[1])
        return [label.rsplit(".", 1)[-1] for label in frames]

    def run_trace(self) -> str:
        simulator = Path(os.environ["GHOST_SIMULATOR"]).resolve()
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / "mixed_trace_contexts.sv"
            path.write_text(SOURCE, encoding="utf-8")
            run = subprocess.run(
                [str(simulator), "--quiet-all", "--lrm-strict", path.name],
                cwd=temporary, capture_output=True, text=True, timeout=60,
            )
        self.assertEqual(run.returncode, 0, run.stderr or run.stdout)
        return run.stdout

    def test_active_class_method_is_visible_between_task_and_function(self):
        actual = self.capture_frames(self.run_trace(), "CLASS")
        self.assertCountEqual(actual, ["capture_leaf", "bridge::capture_middle", "class_outer"])

    def test_each_resumed_fork_task_keeps_its_own_frame(self):
        output = self.run_trace()
        self.assertEqual(self.capture_frames(output, "AFTER"), ["capture_leaf"])
        for context, frame in (("ALPHA", "alpha"), ("BETA", "beta"),
                               ("ALPHA2", "alpha"), ("BETA2", "beta")):
            with self.subTest(context=context):
                self.assertEqual(self.capture_frames(output, context), ["capture_leaf", frame])

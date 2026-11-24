"""Check which VPI and HDL output is visible in Ghost's log before shutdown."""

import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


DESIGN = """\
module flush_visible_during_simulation;
  initial begin
    $display("HDL flush marker 173");
    #1 $vt_flush_now;
    #1 $display("after flush");
  end
endmodule
"""

APPLICATION = r"""
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

static PLI_INT32 emit_and_check(PLI_BYTE8 *unused)
{
    (void)unused;
    vpi_printf("VPI flush marker 229\n");
    int status = vpi_flush();

    int saw_hdl = 0, saw_vpi = 0;
    FILE *log = fopen("during_flush.log", "r");
    if (log != NULL) {
        char line[512];
        while (fgets(line, sizeof line, log) != NULL) {
            saw_hdl |= strstr(line, "HDL flush marker 173") != NULL;
            saw_vpi |= strstr(line, "VPI flush marker 229") != NULL;
        }
        fclose(log);
    }

    vpi_printf("live log after flush: status=%d hdl=%d vpi=%d\n",
               status, saw_hdl, saw_vpi);
    return 0;
}

static void setup(void)
{
    s_vpi_systf_data def = {0};
    def.type = vpiSysTask;
    def.tfname = "$vt_flush_now";
    def.calltf = emit_and_check;
    vpi_register_systf(&def);
}

void (*vlog_startup_routines[])(void) = {setup, NULL};
"""


@unittest.skipUnless(os.environ.get("GHOST_SIMULATOR") and os.environ.get("GHOST_INCLUDE"),
                     "set GHOST_SIMULATOR and GHOST_INCLUDE to run Ghost with VPI")
@unittest.skipUnless(sys.platform in ("darwin", "linux"), "requires a Unix shared library")
class GhostVpiLiveLogFlush(unittest.TestCase):
    def test_flush_makes_both_channels_visible_before_finish(self):
        simulator = Path(os.environ["GHOST_SIMULATOR"]).resolve()
        include = Path(os.environ["GHOST_INCLUDE"]).resolve() / "sukimasim/vpi"
        linker = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []

        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / "test.sv").write_text(DESIGN, encoding="utf-8")
            (root / "flush_probe.c").write_text(APPLICATION, encoding="utf-8")
            library = root / "flush_probe.so"
            build = subprocess.run(
                [os.environ.get("CC", "cc"), "-std=c17", "-shared", "-fPIC", *linker,
                 "-I", str(include), "-o", str(library), "flush_probe.c"],
                cwd=root, capture_output=True, text=True, timeout=60,
            )
            self.assertEqual(build.returncode, 0, build.stderr)

            result = subprocess.run(
                [str(simulator), "--lrm-strict", "--logfile", "during_flush.log",
                 "--lib", str(library), "test.sv"],
                cwd=root, capture_output=True, text=True, timeout=90,
            )
            self.assertEqual(result.returncode, 0, result.stderr or result.stdout)
            self.assertTrue((root / "during_flush.log").is_file())

        lines = result.stdout.splitlines()
        self.assertIn("HDL flush marker 173", lines)
        self.assertIn("VPI flush marker 229", lines)
        self.assertIn("after flush", lines)
        self.assertIn("live log after flush: status=0 hdl=1 vpi=1", lines)

"""Check the VPI representation of file-list options and a nested file list."""

import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


DESIGN = """\
module argument_file_top;
  initial begin
    $display("parsed=%0d,%0d,%0d", `ARGFILE_OUTER, `ARGFILE_INNER, `ARGFILE_AFTER);
    $vt_nested_argument_files;
  end
endmodule
"""

APPLICATION = r"""
#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include "vpi_user.h"

static int is_text(const PLI_BYTE8 *arg, const char *expected)
{
    return arg != NULL && strcmp(arg, expected) == 0;
}

static PLI_BYTE8 *const *as_file(const PLI_BYTE8 *arg, const char *filename)
{
    if (arg == NULL)
        return NULL;

    /* Some simulators supply the filename as a flat argument. Inspect only
       the first pointer's bytes before treating the entry as an array. */
    if (strncmp(arg, filename, sizeof(PLI_BYTE8 *)) == 0 ||
        (uintptr_t)arg % _Alignof(PLI_BYTE8 *) != 0)
        return NULL;

    return (PLI_BYTE8 *const *)(const void *)arg;
}

static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    enum { MISSING, FLAT, OUTER, NESTED } format = MISSING;
    s_vpi_vlog_info info;
    (void)unused;

    if (vpi_get_vlog_info(&info) && info.argv != NULL) {
        for (PLI_INT32 i = 1; i + 1 < info.argc; ++i) {
            if (!is_text(info.argv[i], "-f"))
                continue;

            const char *outer_name = "outer-options.f";
            PLI_BYTE8 *const *outer = as_file(info.argv[i + 1], outer_name);
            if (outer == NULL) {
                format = FLAT;
                break;
            }
            if (!is_text(outer[0], outer_name) ||
                !is_text(outer[1], "+define+ARGFILE_OUTER=17") ||
                !is_text(outer[2], "-f"))
                break;

            format = OUTER;
            const char *inner_name = "inner-options.f";
            PLI_BYTE8 *const *inner = as_file(outer[3], inner_name);
            if (inner != NULL && is_text(inner[0], inner_name) &&
                is_text(inner[1], "+define+ARGFILE_INNER=29") && inner[2] == NULL &&
                is_text(outer[4], "+define+ARGFILE_AFTER=41") && outer[5] == NULL)
                format = NESTED;
            break;
        }
    }
    static const char *const names[] = {"missing", "flat", "outer only", "nested"};
    vpi_printf("argument file structure=%s\n", names[format]);
    return 0;
}

static void setup(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = "$vt_nested_argument_files";
    task.calltf = inspect;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {setup, NULL};
"""


@unittest.skipUnless(os.environ.get("GHOST_SIMULATOR") and os.environ.get("GHOST_INCLUDE"),
                     "set GHOST_SIMULATOR and GHOST_INCLUDE to run Ghost with VPI")
@unittest.skipUnless(sys.platform in ("darwin", "linux"), "requires a Unix shared library")
class GhostVpiArgumentFiles(unittest.TestCase):
    def test_argument_file_is_recursive_and_null_terminated(self):
        simulator = Path(os.environ["GHOST_SIMULATOR"]).resolve()
        include = Path(os.environ["GHOST_INCLUDE"]).resolve() / "sukimasim/vpi"
        linker = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []

        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name, content in {
                "options_probe.c": APPLICATION,
                "argument_file_top.sv": DESIGN,
                "outer-options.f": (
                    "+define+ARGFILE_OUTER=17\n-f inner-options.f\n+define+ARGFILE_AFTER=41\n"
                ),
                "inner-options.f": "+define+ARGFILE_INNER=29\n",
            }.items():
                (root / name).write_text(content, encoding="utf-8")

            build = subprocess.run(
                [os.environ.get("CC", "cc"), "-std=c17", "-shared", "-fPIC", *linker,
                 "-I", str(include), "-o", "options_probe.so", "options_probe.c"],
                cwd=root, capture_output=True, text=True, timeout=60,
            )
            self.assertEqual(build.returncode, 0, build.stderr)
            result = subprocess.run(
                [str(simulator), "--quiet", "--lrm-strict", "--lib", str(root / "options_probe.so"),
                 "-f", "outer-options.f", "argument_file_top.sv"],
                cwd=root, capture_output=True, text=True, timeout=90,
            )

        self.assertEqual(result.returncode, 0, result.stderr or result.stdout)
        self.assertIn("parsed=17,29,41", result.stdout.splitlines())
        self.assertIn("argument file structure=nested", result.stdout.splitlines())

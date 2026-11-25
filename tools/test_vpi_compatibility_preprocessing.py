"""Validate VPI mode selection in the C and C++ headers supplied by a simulator."""

from itertools import combinations
import os
from pathlib import Path
import subprocess
import unittest

from run_vpi_compatibility_headers import (
    LANGUAGES, MODE_ERROR, MODE_PROBE, MODES, ROUTINES, check_mode, compile_source, effective, result_code,
)


class VpiCompatibilityCompilerResult(unittest.TestCase):
    def test_header_diagnostic_is_distinct_from_an_unrelated_compile_failure(self):
        rejection = 'vpi_compatibility.h:38:2: error: Only one VPI_COMPATIBILITY_VERSION symbol is allowed.'
        unrelated = 'vpi_compatibility.h:38:2: error: unexpected VPI_COMPATIBILITY_VERSION token'
        self.assertEqual(result_code(subprocess.CompletedProcess([], 1, "", rejection), MODE_ERROR), "diagnosed")
        self.assertEqual(result_code(subprocess.CompletedProcess([], 1, "", unrelated), MODE_ERROR), "other_error")
        self.assertEqual(result_code(subprocess.CompletedProcess([], -9, "", rejection), MODE_ERROR), "crashed")
        self.assertEqual(result_code(subprocess.CompletedProcess([], 0, "mode_probe vpi_get_1800v2012\n", ""),
                                     MODE_ERROR), "selected_1800v2012")

    def test_success_requires_every_routine_to_select_the_same_branch(self):
        output = "mode_probe vpi_get_1800v2012\n" + "\n".join(f"mode_routine {name}_1800v2012" for name in ROUTINES)
        self.assertEqual(check_mode(subprocess.CompletedProcess([], 0, output, "")), "selected_1800v2012")
        split_mode = output.replace("vpi_scan_1800v2012", "vpi_scan_1364v2001")
        self.assertEqual(check_mode(subprocess.CompletedProcess([], 0, split_mode, "")), "inconsistent_routine_selection")


@unittest.skipUnless(os.environ.get("VPI_INCLUDE"), "set VPI_INCLUDE to test vpi_user.h")
class VpiCompatibilityPreprocessing(unittest.TestCase):
    def preprocess(self, language, compiler, *modes, source=MODE_PROBE):
        include = Path(os.environ["VPI_INCLUDE"]).resolve()
        return compile_source(compiler, language, include, modes, source)

    def test_each_single_mode_selects_its_routine(self):
        for language, variable, default in LANGUAGES:
            compiler = os.environ.get(variable, default)
            for mode in MODES:
                with self.subTest(language=language, mode=mode):
                    result = self.preprocess(language, compiler, mode)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertIn(f"mode_probe vpi_get_{effective(mode)}", result.stdout.splitlines())

    def test_every_pair_of_mode_macros_is_rejected(self):
        for language, variable, default in LANGUAGES:
            compiler = os.environ.get(variable, default)
            for first, second in combinations(MODES, 2):
                with self.subTest(language=language, first=first, second=second):
                    result = self.preprocess(language, compiler, first, second)
                    self.assertGreater(result.returncode, 0, "vpi_user.h accepted both modes")
                    self.assertRegex(
                        result.stderr,
                        r"(?i)error[^\n]*(?:VPI_COMPATIBILITY_VERSION|compatibility mode)",
                    )

    def test_public_header_can_be_reincluded_with_the_compatibility_guard_set(self):
        source = (
            '#include "vpi_user.h"\n#include "vpi_user.h"\n'
            '#ifdef VPI_COMPATIBILITY_H\ncompatibility_guard_present\n#endif\n'
            'mode_probe vpi_get\n'
        )
        for language, variable, default in LANGUAGES:
            with self.subTest(language=language):
                result = self.preprocess(language, os.environ.get(variable, default),
                                         "1364v2001", source=source)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn("compatibility_guard_present", result.stdout.splitlines())
                self.assertIn("mode_probe vpi_get_1364v2001", result.stdout.splitlines())

    def test_reentering_the_compatibility_header_is_diagnosed(self):
        source = '#include "vpi_user.h"\n#include "vpi_compatibility.h"\n'
        for language, variable, default in LANGUAGES:
            with self.subTest(language=language):
                result = self.preprocess(language, os.environ.get(variable, default),
                                         "1364v2001", source=source)
                self.assertGreater(result.returncode, 0, result.stdout.splitlines()[-5:])
                self.assertRegex(result.stderr, r"(?is)error.*vpi_compatibility\.h.*includ")

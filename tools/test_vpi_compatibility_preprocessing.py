"""Validate VPI mode selection in the C and C++ headers supplied by a simulator."""

from itertools import combinations
import os
from pathlib import Path
import subprocess
import unittest


MODES = (
    "1364v1995", "1364v2001", "1364v2005", "1800v2005",
    "1800v2009", "1800v2012", "1800v2017", "1800v2023",
)
LANGUAGES = (("c", "CC", "cc"), ("c++", "CXX", "c++"))
MODE_PROBE = '#include "vpi_user.h"\nmode_probe vpi_get\n'


@unittest.skipUnless(os.environ.get("VPI_INCLUDE"), "set VPI_INCLUDE to test vpi_user.h")
class VpiCompatibilityPreprocessing(unittest.TestCase):
    def preprocess(self, language, compiler, *modes, source=MODE_PROBE):
        include = Path(os.environ["VPI_INCLUDE"]).resolve()
        definitions = [f"-DVPI_COMPATIBILITY_VERSION_{mode}=1" for mode in modes]
        return subprocess.run(
            [compiler, "-E", "-P", "-x", language, "-I", str(include), *definitions, "-"],
            input=source,
            capture_output=True,
            text=True,
            timeout=60,
        )

    def test_each_single_mode_selects_its_routine(self):
        for language, variable, default in LANGUAGES:
            compiler = os.environ.get(variable, default)
            for mode in MODES:
                with self.subTest(language=language, mode=mode):
                    result = self.preprocess(language, compiler, mode)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    selected = "1800v2012" if mode in ("1800v2017", "1800v2023") else mode
                    self.assertIn(f"mode_probe vpi_get_{selected}", result.stdout.splitlines())

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

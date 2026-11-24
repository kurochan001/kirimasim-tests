"""Inspect the replacement lists in a simulator's svdpi.h without executing them."""

import os
from pathlib import Path
import re
import subprocess
import unittest


SIGNED = "((N)==32?(VALUE):(((VALUE)&(1<<(N)))?((VALUE)|~SV_MASK(N)):((VALUE)&SV_MASK(N))))"
C_TOKEN = re.compile(r"[A-Za-z_]\w*|[0-9]+|<<|>>|==|!=|&&|\|\||[^\s]")


def signed_macro_tokens(preprocessed: str) -> list[str]:
    """Read the function-like definition, leaving other macros unexpanded."""
    definition = re.search(
        r"^#\s*define\s+SV_GET_SIGNED_BITS\(([^)]*)\)[ \t]*(.*)$", preprocessed, re.MULTILINE
    )
    if definition is None:
        raise ValueError("SV_GET_SIGNED_BITS has no function-like definition")
    parameters = [part.strip() for part in definition[1].split(",")]
    if len(parameters) != 2 or len(set(parameters)) != 2:
        raise ValueError("SV_GET_SIGNED_BITS needs two distinct parameters")
    names = dict(zip(parameters, ("VALUE", "N")))
    return [names.get(token, token) for token in C_TOKEN.findall(definition[2])]


class ReplacementListTest(unittest.TestCase):
    def test_tokens_keep_the_shift_operator_distinct(self):
        prefix = "#define SV_GET_SIGNED_BITS(v,n) "
        definition = re.sub(r"\bVALUE\b", "v", SIGNED)
        definition = re.sub(r"\bN\b", "n", definition)
        exact = C_TOKEN.findall(SIGNED)
        self.assertEqual(signed_macro_tokens(prefix + definition), exact)
        self.assertNotEqual(signed_macro_tokens(prefix + definition.replace("<<", "< <")), exact)
        self.assertNotEqual(signed_macro_tokens(prefix + "other_macro(v,n)"), exact)


@unittest.skipUnless(os.environ.get("SVDPI_INCLUDE"), "set SVDPI_INCLUDE to inspect a simulator header")
class SvdpiHeaderPreprocessing(unittest.TestCase):
    def preprocess(self, before: str = "") -> str:
        include = Path(os.environ["SVDPI_INCLUDE"]).resolve()
        result = subprocess.run(
            [os.environ.get("CC", "cc"), "-x", "c", "-E", "-dD", "-I", str(include), "-"],
            input=before + '\n#include "svdpi.h"\n',
            capture_output=True,
            text=True,
            timeout=60,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout

    def test_signed_macro_has_the_printed_replacement_list(self):
        self.assertEqual(signed_macro_tokens(self.preprocess()), C_TOKEN.findall(SIGNED))

    def test_import_and_export_macros_use_the_default_extern(self):
        definitions = self.preprocess()
        self.assertRegex(definitions, r"(?m)^#define DPI_EXTERN[ \t]*$")
        self.assertRegex(definitions, r"(?m)^#define XXTERN DPI_EXTERN DPI_DLLISPEC[ \t]*$")
        self.assertRegex(definitions, r"(?m)^#define EETERN DPI_EXTERN DPI_DLLESPEC[ \t]*$")

    def test_caller_extern_reaches_the_import_declarations(self):
        definitions = self.preprocess("#define DPI_EXTERN caller_external")
        self.assertEqual(re.findall(r"(?m)^#define DPI_EXTERN[^\n]*$", definitions),
                         ["#define DPI_EXTERN caller_external"])
        self.assertRegex(definitions, r"(?m)^caller_external\s+const char\s*\*\s*svDpiVersion\(")

    def test_prior_prototype_guard_keeps_caller_import_and_export_macros(self):
        definitions = self.preprocess(
            "#define DPI_PROTOTYPES\n#define XXTERN caller_import\n#define EETERN caller_export"
        )
        self.assertEqual(re.findall(r"(?m)^#define XXTERN[^\n]*$", definitions),
                         ["#define XXTERN caller_import"])
        self.assertEqual(re.findall(r"(?m)^#define EETERN[^\n]*$", definitions),
                         ["#define EETERN caller_export"])
        self.assertRegex(definitions, r"(?m)^caller_import\s+const char\s*\*\s*svDpiVersion\(")

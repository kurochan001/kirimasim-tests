"""Regression tests for the protected pragma qualification checker."""

import unittest

from run_protect_pragma_syntax import PREFIX, mismatch_status, replacements


class ProtectPragmaSyntaxTests(unittest.TestCase):
    def test_a_bare_block_gets_a_single_extra_argument(self):
        source = PREFIX + "data_block"
        self.assertEqual(list(replacements(source, "data_block")), [("extra_argument", source + "=1")])

    def test_only_the_selected_delimiter_is_changed(self):
        source = PREFIX + "end, reset"
        self.assertEqual(list(replacements(source, "reset")), [
            ("extra_argument", PREFIX + "end, reset=1"),
        ])

    def test_named_field_mutations_keep_other_fields_and_their_order(self):
        source = PREFIX + 'encoding=(enctype="base64", line_length=76, bytes=3)'
        self.assertEqual(dict(replacements(source, "encoding")), {
            "enctype_wrong_type": PREFIX + 'encoding=(enctype=base64, line_length=76, bytes=3)',
            "enctype_missing": PREFIX + 'encoding=(line_length=76, bytes=3)',
            "line_length_wrong_type": PREFIX + 'encoding=(enctype="base64", line_length="1", bytes=3)',
            "bytes_wrong_type": PREFIX + 'encoding=(enctype="base64", line_length=76, bytes="1")',
        })

    def test_error_must_be_on_the_changed_directive(self):
        actual = ["probe.sv:7:25: error: invalid pragma argument"]
        self.assertEqual(mismatch_status(1, actual, "probe.sv", 7), "rejected_at_line")
        self.assertEqual(mismatch_status(1, actual, "probe.sv", 8), "rejected_elsewhere")
        self.assertEqual(mismatch_status(1, actual, "other.sv", 7), "rejected_elsewhere")
        self.assertEqual(mismatch_status(-9, actual, "probe.sv", 7), "compiler_failure")
        self.assertEqual(mismatch_status(None, [], "probe.sv", 7), "compiler_failure")
        self.assertEqual(mismatch_status(0, [], "probe.sv", 7), "accepted")


if __name__ == "__main__":
    unittest.main()

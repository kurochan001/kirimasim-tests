"""Check method verdicts without depending on an installed encryptor."""

from pathlib import Path
import unittest
from unittest.mock import patch

import run_protect_cipher_methods as checker


class CipherMethodTests(unittest.TestCase):
    def test_required_method_cannot_be_reported_as_optional(self):
        self.assertEqual(
            checker.rejected_method("des-cbc", 1, b"no support: des-cbc unsupported"),
            "encryptor_error",
        )
        self.assertEqual(
            checker.rejected_method("twofish192-cbc", 1, b"unsupported cipher: twofish192-cbc"),
            "unsupported_optional_method",
        )
        for diagnostic in (b"unsupported cipher: twofish256-cbc",
                           b"unsupported cipher: custom-twofish192-cbc",
                           b"unexpected EOF following twofish192-cbc"):
            with self.subTest(diagnostic=diagnostic):
                self.assertEqual(checker.rejected_method("twofish192-cbc", 1, diagnostic), "encryptor_error")
        self.assertEqual(
            checker.rejected_method("twofish192-cbc", -9, b"unsupported cipher: twofish192-cbc"),
            "encryptor_error",
        )

    def test_recovered_body_does_not_make_a_substituted_method_pass(self):
        envelope = (b"`pragma protect begin_protected\n"
                    b'`pragma protect data_method = "aes256-cbc"\n'
                    b"`pragma protect end_protected\n")
        expected = (b"assignment", b"assignment")
        with patch.object(checker, "recover_body", return_value=(b"assignment", bytes(16))) as recover:
            result, ivs = checker.inspect_method(
                "openssl", Path("nettle"), Path("private"), "des-cbc", envelope * 2, expected,
            )
        self.assertEqual(recover.call_count, 2)
        self.assertEqual(result["outcome"], "substituted_method")
        self.assertEqual(result["emitted"], ["aes256-cbc", "aes256-cbc"])
        self.assertEqual(result["recovered_bodies"], 2)
        self.assertEqual(result["distinct_recovered_ivs"], 1)
        self.assertEqual(len(ivs), 2)

    def test_decryption_compares_content_and_padding(self):
        self.assertTrue(checker.body_matches(b"source", b"source", 8))
        self.assertTrue(checker.body_matches(b"source", b"source\x02\x02", 8))
        self.assertFalse(checker.body_matches(b"source", b"source\x01\x02", 8))
        self.assertFalse(checker.body_matches(b"source", b"different\x01", 8))


if __name__ == "__main__":
    unittest.main()

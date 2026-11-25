"""Check diagnostic matching and structured key extraction."""

from pathlib import Path
from subprocess import CompletedProcess
import unittest

import run_protect_block_boundaries as checker
import run_protect_digests as digests


class BlockBoundaryTests(unittest.TestCase):
    def test_rejection_requires_a_normal_error_at_the_inserted_line(self):
        path = Path("fixture.sv")
        diagnostic = b"/tmp/fixture.sv:17:3: error: invalid key_block"
        self.assertTrue(checker.rejected_at_variant(CompletedProcess([], 1, b"", diagnostic),
                                                    path, 17, b"key_block"))
        for code, message in ((0, diagnostic), (-9, diagnostic),
                              (1, diagnostic.replace(b"17:", b"18:")),
                              (1, diagnostic.replace(b"key_block", b"data_block")),
                              (1, diagnostic.replace(b"error", b"warning"))):
            with self.subTest(code=code, message=message):
                self.assertFalse(checker.rejected_at_variant(CompletedProcess([], code, b"", message),
                                                             path, 17, b"key_block"))

    def test_structured_key_recovers_method_and_size_from_both_encodings(self):
        method = b'`pragma protect data_method = "aes256-cbc"\n'
        key = bytes(range(32))
        for codec in (b"base64", b"uuencode"):
            with self.subTest(codec=codec):
                text = method + digests.encoded_block(b"data_decrypt_key", key, codec)
                self.assertEqual(checker.text_key(text), (b"aes256-cbc", key))
                with self.assertRaisesRegex(ValueError, "incorrect decoded key length"):
                    checker.text_key(text.replace(b"bytes=32", b"bytes=31"))
                with self.assertRaisesRegex(ValueError, "next-line data key"):
                    checker.text_key(text.replace(b"data_decrypt_key\n", b"data_decrypt_key\n\n"))


if __name__ == "__main__":
    unittest.main()

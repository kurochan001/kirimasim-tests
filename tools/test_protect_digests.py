"""Check digest ordering, encoding and key selection with small local inputs."""

import unittest

import run_protect_digests as checker


class DigestTests(unittest.TestCase):
    def test_each_digest_stays_with_its_preceding_block_in_both_encodings(self):
        payloads = (b"wrapped key", b"key digest", b"encrypted body", b"body digest")
        for enctype in (b"base64", b"uuencode"):
            with self.subTest(enctype=enctype):
                chunks = [checker.encoded_block(kind, data, enctype)
                          for kind, data in zip(checker.BLOCK_ORDER, payloads)]
                self.assertEqual(checker.payloads(b"".join(chunks), enctype), payloads)
                with self.assertRaisesRegex(ValueError, "adjacent digest"):
                    checker.payloads(b"".join(chunks[0:1] + chunks[2:] + chunks[1:2]), enctype)
                with self.assertRaisesRegex(ValueError, "unrelated pragma"):
                    checker.payloads(chunks[0] + b'`pragma protect comment = "split"\n'
                                     + b"".join(chunks[1:]), enctype)

    def test_first_payload_line_and_byte_count_are_checked(self):
        encoded = b"".join(checker.encoded_block(kind, b"abc", b"base64") for kind in checker.BLOCK_ORDER)
        blank = encoded.replace(b"digest_block\n", b"digest_block\n\n", 1)
        with self.assertRaisesRegex(ValueError, "following line"):
            checker.payloads(blank, b"base64")
        wrong_count = encoded.replace(b"bytes=3", b"bytes=4", 1)
        with self.assertRaisesRegex(ValueError, "bytes descriptor"):
            checker.payloads(wrong_count, b"base64")

    def test_explicit_digest_key_is_distinct_from_default_session_key(self):
        session_key = bytes(range(32))
        header = {b"data_method": b"aes256-cbc"}
        self.assertEqual(checker.digest_cipher(header, session_key), ("aes256-cbc", session_key))
        header = {b"data_method": b"aes256-cbc", b"digest_key_method": b"aes128-cbc",
                  b"digest_keyowner": b"Digest Fixture", b"digest_keyname": b"digest-aes128"}
        self.assertEqual(checker.digest_cipher(header, session_key), ("aes128-cbc", bytes(range(16))))
        header[b"digest_keyname"] = b"another-key"
        with self.assertRaises(KeyError):
            checker.digest_cipher(header, session_key)


if __name__ == "__main__":
    unittest.main()

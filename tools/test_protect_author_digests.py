import unittest

import run_protect_author_digests as author
from run_protect_digests import encoded_block


class AuthorDigestMetadataTests(unittest.TestCase):
    def setUp(self):
        self.key = bytes(range(32))
        self.data = (
            author.method_line(b"data_method", b"aes256-cbc")
            + encoded_block(author.DATA_KEY, self.key, b"uuencode")
        )

    def test_explicit_digest_key_has_its_own_method_and_encoding(self):
        digest_key = b"x" * 16
        text = (
            self.data + author.method_line(b"digest_key_method", b"aes128-cbc")
            + encoded_block(author.DIGEST_KEY, digest_key, b"base64")
        )

        self.assertEqual(author.resolve_keys(text),
                         author.DigestKeys(b"aes256-cbc", self.key, b"aes128-cbc", digest_key))

    def test_absent_digest_metadata_uses_the_current_data_key(self):
        self.assertEqual(author.resolve_keys(self.data),
                         author.DigestKeys(b"aes256-cbc", self.key, b"aes256-cbc", self.key))

    def test_declared_key_length_must_match_the_decoded_data(self):
        with self.assertRaisesRegex(ValueError, "decoded bytes"):
            author.resolve_keys(self.data.replace(b"bytes=32", b"bytes=31"))

    def test_payload_must_start_on_the_next_line(self):
        text = self.data.replace(author.DATA_KEY + b"\n", author.DATA_KEY + b"\n\n")

        with self.assertRaisesRegex(ValueError, "next line"):
            author.resolve_keys(text)


if __name__ == "__main__":
    unittest.main()

import unittest

from run_protect_encodings import Field, encode_field, read_fields


class ProtectEncodingTests(unittest.TestCase):
    def test_raw_count_keeps_pragma_text_and_final_newline_as_payload(self):
        raw = b"\x00\n`pragma protect key_block\n\xff\n"
        wrapped = b"wrapped key"
        envelope = (encode_field(b"data_block", b"raw", raw)
                    + encode_field(b"key_block", b"base64", wrapped))

        self.assertEqual(read_fields(envelope), {
            b"data_block": Field(b"raw", raw),
            b"key_block": Field(b"base64", wrapped),
        })

    def test_quoted_printable_soft_break_can_expose_pragma_text(self):
        raw = b"prefix`pragma protect data_block"
        header = b'`pragma protect encoding=(enctype="quoted-printable", bytes=32)\n'
        envelope = (header + b"`pragma protect data_block\nprefix=\n`pragma protect data_block\n"
                    + encode_field(b"digest_block", b"uuencode", b"digest"))

        self.assertEqual(read_fields(envelope), {
            b"data_block": Field(b"quoted-printable", raw),
            b"digest_block": Field(b"uuencode", b"digest"),
        })

    def test_malformed_quoted_printable_escape_is_rejected(self):
        envelope = encode_field(b"data_block", b"quoted-printable", b"\xff")

        with self.assertRaisesRegex(ValueError, "invalid quoted-printable escape"):
            read_fields(envelope.replace(b"=FF", b"=FX"))


if __name__ == "__main__":
    unittest.main()

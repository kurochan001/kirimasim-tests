"""Exercise the qualification checker independently of the external encryptor."""

import base64
import binascii
import textwrap
import unittest
from unittest.mock import patch

import run_protect_encryption as checker
import suite_results


class ProtectEncryptionTests(unittest.TestCase):
    def setUp(self):
        case = "ch34/test_protect_exports_author_fields_and_limits_encoded_lines"
        self.source = (suite_results.ROOT / "tests" / f"{case}.sv").read_bytes()
        original = checker.split(self.source, checker.SOURCE_BEGIN, checker.SOURCE_END)
        self.recovered = {}
        output = []
        for index, body in enumerate(original.bodies):
            data = bytes([index]) * 64
            self.recovered[data] = b"/* added comment */\n" + checker.without_directives(
                body, checker.EXPORTED
            ).strip(b"\n") + b"\n// another comment\n"
            fields = [line for line in body.splitlines() if checker.fields(line).keys()
                      & {b"author", b"author_info", b"comment"}]
            author, author_info, comment = fields
            encoded = "\n".join(textwrap.wrap(base64.b64encode(data).decode(), (24, 32)[index])).encode()
            output.extend((
                checker.without_directives(original.clear[index], checker.CONTROLS),
                b"`pragma protect begin_protected\n`pragma protect version = 2\n",
                b'`pragma protect encrypt_agent = "Python IEEE 1735 Encryptor"\n',
                b'`pragma protect data_method = "aes256-cbc"\n',
                author + b"\n" + author_info + b"\n",
                b'`pragma protect encoding = (enctype="base64", bytes=3)\n',
                b"`pragma protect key_block\n" + base64.b64encode(b"key") + b"\n",
                b'`pragma protect encoding = (enctype="base64", bytes=64)\n',
                comment + b"\n`pragma protect data_block\n", encoded,
                b"\n`pragma protect end_protected",
            ))
        self.encrypted = b"".join(output) + original.clear[-1]

    def decode(self, blocks):
        return self.recovered[blocks[b"data_block"].decoded]

    def test_conventional_output_matches_all_checks(self):
        checks = checker.inspect(self.source, self.encrypted, self.decode)
        self.assertEqual([name for name, matches in checks.items() if not matches], [])

    def test_payload_can_be_observed_with_a_missing_opening_delimiter(self):
        missing = self.encrypted.replace(b"`pragma protect begin_protected\n", b"", 1)
        checks = checker.inspect(self.source, missing, self.decode)
        self.assertFalse(checks["begin_output"])
        self.assertFalse(checks["envelope_replacement"])
        self.assertTrue(checks["body_preserved"])

    def test_wrong_byte_count_and_lost_whitespace_are_distinct(self):
        wrong = self.encrypted.replace(b"bytes=64", b"bytes=63", 1)
        self.recovered[b"\x01" * 64] = self.recovered[b"\x01" * 64].replace(b"\n  /* Leading", b"\n/* Leading")
        checks = checker.inspect(self.source, wrong, self.decode)
        self.assertFalse(checks["explicit_descriptors"])
        self.assertFalse(checks["ignored_input_byte_hint"])
        self.assertFalse(checks["body_preserved"])
        self.assertTrue(checks["session_key"])


class ExchangeRoleTests(unittest.TestCase):
    def setUp(self):
        self.source = (suite_results.ROOT / "tests" / f"{checker.EXCHANGE_CASE}.sv").read_bytes()
        original = checker.split(self.source, checker.SOURCE_BEGIN, checker.SOURCE_END)
        self.plain = {}
        output = []
        for index, (body, cipher) in enumerate(zip(original.bodies, (b"aes256-cbc", b"aes128-cbc"))):
            payload = bytes([index]) * 32
            self.plain[payload] = checker.without_directives(body, checker.EXPORTED)
            metadata = [line for line in body.splitlines() if checker.fields(line).keys() & set(checker.EXPORTED)]
            if index == 0:
                enctype = b"base64"
                encoded_key = base64.b64encode(b"key") + b"\n"
                encoded_body = "\n".join(textwrap.wrap(base64.b64encode(payload).decode(), 32)).encode() + b"\n"
            else:
                enctype = b"uuencode"
                encoded_key = binascii.b2a_uu(b"key")
                encoded_body = binascii.b2a_uu(payload, backtick=True)
            descriptor = b'`pragma protect encoding = (enctype="' + enctype + b'", bytes='
            output.extend((
                original.clear[index],
                b"`pragma protect begin_protected\n`pragma protect version = 2\n",
                b'`pragma protect encrypt_agent = "Python IEEE 1735 Encryptor"\n',
                b'`pragma protect key_keyowner = "Fixture East", key_keyname = "assembly", key_method = "rsa"\n',
                b'\n'.join(metadata) + b'\n',
                descriptor + b'3)\n',
                b'`pragma protect key_block\n' + encoded_key,
                b'`pragma protect data_method = "' + cipher + b'"\n',
                descriptor + b'32)\n',
                b'`pragma protect data_block\n' + encoded_body,
                b'`pragma protect end_protected',
            ))
        self.encrypted = b"".join(output) + original.clear[-1]

    def open_body(self, identity, cipher, blocks):
        if identity != checker.RECIPIENTS[0]:
            raise ValueError("wrong recipient")
        return self.plain[blocks[b"data_block"].decoded], True

    def test_every_envelope_has_independent_roles(self):
        checks = checker.keyword_roles(self.source, self.encrypted, checker.RECIPIENTS[0], self.open_body)
        self.assertEqual([name for name, matches in checks.items() if not matches], [])

    def test_wrong_key_name_cannot_pass_payload_recovery(self):
        changed = self.encrypted.replace(b'key_keyname = "assembly"', b'key_keyname = "backup"', 1)
        checks = checker.keyword_roles(self.source, changed, checker.RECIPIENTS[0], self.open_body)
        self.assertTrue(checks["key_owner"])
        self.assertFalse(checks["key_name"])
        self.assertFalse(checks["key_ciphertext"])
        self.assertFalse(checks["body_ciphertext"])

    def test_missing_opening_only_invalidates_beginning_and_self_containment(self):
        changed = self.encrypted.replace(b"`pragma protect begin_protected\n", b"", 1)
        checks = checker.keyword_roles(self.source, changed, checker.RECIPIENTS[0], self.open_body)
        self.assertFalse(checks["begin_decryption"])
        self.assertFalse(checks["self_contained"])
        self.assertTrue(checks["end_decryption"])
        self.assertTrue(checks["body_ciphertext"])

    def test_cipher_identifiers_select_openssl_options(self):
        for cipher, size, option in ((b"aes128-cbc", 16, "-aes-128-cbc"),
                                     (b"aes256-cbc", 32, "-aes-256-cbc")):
            with self.subTest(cipher=cipher), patch.object(checker, "invoke") as invoke:
                checker.decrypt_body("openssl", cipher, bytes(size), bytes(32))
                self.assertEqual(invoke.call_args.args[0][:4], ["openssl", "enc", "-d", option])

    def test_framed_uuencode_requires_termination(self):
        lines = (b"begin 644 key", binascii.b2a_uu(b"key").rstrip(b"\n"), b"`", b"end")
        self.assertEqual(checker.decode_payload(lines, b"uuencode"), b"key")
        with self.assertRaisesRegex(ValueError, "framing"):
            checker.decode_payload(lines[:-1], b"uuencode")


if __name__ == "__main__":
    unittest.main()

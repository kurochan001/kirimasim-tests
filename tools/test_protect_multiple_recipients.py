from dataclasses import replace
from pathlib import Path
import unittest
from unittest.mock import patch

import run_protect_multiple_recipients as multi
from run_protect_public_keys import Selection


class MultipleRecipientTests(unittest.TestCase):
    def setUp(self):
        self.data = multi.BodyKey(b"author", b"design", b"aes256-cbc", b"k" * 32)
        self.first = multi.Recipient(Selection(b"east", b"delivery", b"rsa"), b"base64", self.data)
        self.second = multi.Recipient(
            Selection(b"west", b"delivery", b"aes128-cbc"), b"uuencode", self.data,
        )

    def test_recipient_selection_and_encoding_can_vary(self):
        self.assertEqual(multi.shared_data((self.first, self.second)), self.data)

    def test_matching_key_material_is_compared_before_crypto(self):
        changes = {"owner": b"archive", "name": b"nightly", "method": b"aes128-cbc", "key": b"z" * 32}
        with patch.object(multi.protect, "invoke") as invoke, patch.object(multi, "wrap_one") as wrap:
            for field, keyword in multi.DATA_FIELDS:
                with self.subTest(field=field):
                    changed = replace(self.second, data=replace(self.data, **{field: changes[field]}))
                    self.assertTrue(multi.rejected_before_key_block_generation(
                        "openssl", Path("."), (self.first, changed), {}, b"body",
                        Path("author.pem"), Path("author.sig"), keyword,
                    ))
            invoke.assert_not_called()
            wrap.assert_not_called()

    def test_registry_rejects_duplicate_identity_only_within_owner(self):
        key = multi.ExchangeKey(b"aes128-cbc", b"k" * 16)
        other_owner = [(b"east", b"delivery"), (b"west", b"delivery")]
        self.assertEqual(len(multi.registry([(identity, key) for identity in other_owner])), 2)

        with self.assertRaisesRegex(ValueError, "duplicate exchange key material"):
            multi.registry([((b"east", b"delivery"), key), ((b"east", b"backup"), key)])


if __name__ == "__main__":
    unittest.main()

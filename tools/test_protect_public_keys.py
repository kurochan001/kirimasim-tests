from pathlib import Path
import unittest

import run_protect_public_keys as public


class PublicKeySelectionTests(unittest.TestCase):
    def setUp(self):
        self.east = public.KeyPair(Path("east.pem"), b"east")
        self.west = public.KeyPair(Path("west.pem"), b"west")
        self.keys = {(public.EAST, public.ASSEMBLY): self.east,
                     (public.WEST, public.ASSEMBLY): self.west}

    def test_owner_resolves_reused_name(self):
        request = public.Selection(public.WEST, public.ASSEMBLY, b"rsa")

        self.assertEqual(public.encryption_key(request, public.DATA_FIELDS, self.keys), b"west")
        self.assertEqual(public.decryption_key(request, public.DATA_FIELDS, self.keys), self.west)

    def test_known_public_key_for_another_owner_cannot_select_private_key(self):
        request = public.Selection(public.WEST, None, b"rsa", self.east.public_der)

        self.assertEqual(public.encryption_key(request, public.DATA_FIELDS, self.keys), b"east")
        with self.assertRaisesRegex(ValueError, "for this owner"):
            public.decryption_key(request, public.DATA_FIELDS, self.keys)

    def test_inherited_digest_public_key_is_checked_against_explicit_name(self):
        initial = public.Selection(public.EAST, public.ASSEMBLY, b"rsa", self.east.public_der)
        explicit = public.Selection(public.WEST, public.ASSEMBLY, b"rsa")
        text = public.selection_text(explicit, public.DIGEST_FIELDS, b"uuencode")
        selected = public.read_selection(text, public.DIGEST_FIELDS, fallback=initial)

        self.assertEqual(selected.public_der, b"east")
        with self.assertRaisesRegex(ValueError, "named and embedded public keys differ"):
            public.encryption_key(selected, public.DIGEST_FIELDS, self.keys)

    def test_diagnostic_belongs_to_requested_selector_and_owner(self):
        request = public.Selection(public.EAST, b"missing", b"rsa", self.east.public_der)
        text = public.selection_text(request, public.KEY_FIELDS, b"base64")

        self.assertTrue(public.unknown_name_at_selector(
            text, public.KEY_FIELDS, self.keys, public.EAST, b"missing"))
        self.assertFalse(public.unknown_name_at_selector(
            text, public.KEY_FIELDS, self.keys, public.WEST, b"missing"))


if __name__ == "__main__":
    unittest.main()

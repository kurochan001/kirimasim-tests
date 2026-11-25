import unittest
from unittest.mock import patch

import run_protect_nested_decryption as nested


class NestedReplacementTests(unittest.TestCase):
    def test_next_sibling_is_opened_after_the_inner_and_outer_closes(self):
        begin = b"`pragma protect begin_protected\n"
        end = b"\n`pragma protect end_protected\n"
        outer, inner, sibling = [
            nested.Header(name, b"assembly", b"aes128-cbc", b"aes256-cbc", b"base64")
            for name in (b"outer", b"inner", b"sibling")
        ]
        ciphertext = begin + b"outer" + end + begin + b"sibling" + end
        plaintext = {
            b"outer": (outer, b"before " + b"\n" + begin + b"inner" + end),
            b"inner": (inner, b"`define INSIDE 1"),
            b"sibling": (sibling, b"value = `INSIDE;"),
        }
        trace = []
        with patch.object(nested, "open_envelope", side_effect=lambda _, wire, keys: plaintext[wire.strip()]):
            restored = nested.replace_envelopes("openssl", ciphertext, {}, trace)

        self.assertEqual(trace, [
            ("open", 1, outer), ("open", 2, inner), ("close", 2, inner),
            ("close", 1, outer), ("open", 1, sibling), ("close", 1, sibling),
        ])
        self.assertLess(restored.index(b"`define INSIDE"), restored.index(b"value = `INSIDE"))

    def test_unclosed_outer_envelope_is_rejected_before_decryption(self):
        ciphertext = b"`pragma protect begin_protected\nciphertext\n"

        with patch.object(nested, "open_envelope") as decrypt:
            with self.assertRaisesRegex(ValueError, "unclosed envelope"):
                nested.replace_envelopes("openssl", ciphertext, {}, [])
            decrypt.assert_not_called()


if __name__ == "__main__":
    unittest.main()

import unittest

import run_protect_openpgp_methods as pgp


class OpenPgpPacketTests(unittest.TestCase):
    def test_requires_one_session_key_packet(self):
        line = b":pubkey enc packet: version 3, algo 16, keyid aabbccddeeff0011\n"
        self.assertEqual(pgp.packet_summary(line), pgp.Packet(3, 16, b"AABBCCDDEEFF0011"))

        with self.assertRaisesRegex(ValueError, "expected one"):
            pgp.packet_summary(line * 2)

    def test_rejects_wrong_label_or_recipient(self):
        packet = pgp.Packet(3, 1, b"AABBCCDDEEFF0011")
        fingerprint = "1234567890000000AABBCCDDEEFF0011"
        pgp.validate_packet(b"pgp-rsa", packet, fingerprint)
        with self.assertRaisesRegex(ValueError, "selected method"):
            pgp.validate_packet(b"elgamal", packet, fingerprint)
        with self.assertRaisesRegex(ValueError, "another recipient"):
            pgp.validate_packet(b"pgp-rsa", packet, fingerprint[:-1] + "2")

    def test_elgamal_arithmetic_vector_recovers_original(self):
        self.assertTrue(pgp.elgamal_known_answer())


if __name__ == "__main__":
    unittest.main()

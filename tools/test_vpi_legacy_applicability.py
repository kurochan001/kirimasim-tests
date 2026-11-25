import unittest

import run_vpi_legacy_applicability as vpi


class LegacyObjectModelTests(unittest.TestCase):
    def test_a_missing_class_cannot_satisfy_an_empty_relationship(self):
        mode = "1364v1995"
        lines = list(vpi.class_output(mode))
        lines[0] = lines[0].replace("defn=1", "defn=0")

        self.assertEqual(vpi.assess(vpi.CLASS, mode, "\n".join([f"abi=vpi_iterate_{mode}", *lines]))[0],
                         "fail")

    def test_same_real_root_is_valid_in_2001_and_a_difference_in_1995(self):
        body = (vpi.REAL_ROOT_LEGACY, vpi.INT_TIME_LEGACY, vpi.REAL_VALUES, vpi.HDL_VALUES)
        older = "\n".join(["abi=vpi_get_1364v1995", *body])
        later = "\n".join(["abi=vpi_get_1364v2001", *body])

        self.assertEqual(vpi.assess(vpi.REAL, "1364v1995", older),
                         ("fail", "real array root reported as vpiRealVar in 1364-1995"))
        self.assertEqual(vpi.assess(vpi.REAL, "1364v2001", later), ("pass", ""))

    def test_accepts_absence_of_the_array_in_the_oldest_view(self):
        body = (vpi.REAL_ROOT_HIDDEN, vpi.INT_TIME_LEGACY, "vpi=2.25,0.00,0.00", vpi.HDL_VALUES)
        result = vpi.assess(vpi.REAL, "1364v1995", "\n".join(["abi=vpi_get_1364v1995", *body]))

        self.assertEqual(result, ("pass", ""))

    def test_rejects_a_default_entry_point_even_if_the_objects_match(self):
        matching = "\n".join(["abi=vpi_iterate", *vpi.class_output("1364v2001")])

        self.assertEqual(vpi.assess(vpi.CLASS, "1364v2001", matching),
                         ("fail", "wrong compatibility entry point"))


if __name__ == "__main__":
    unittest.main()

"""record_oracles.py changes only the tokens of the simulators given, keeps
both releases, the comments and the order, and skips unregistered matches."""

import json
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
import common
import record_oracles as ro


def case(name, fourstate=False, unregistered=()):
    return common.Case(name=name, description="d", lrm="11.4", comment="c",
                       body="module m; endmodule", expected="ok\n", fourstate=fourstate,
                       unregistered=unregistered)


LINES = ["# header", "test_gen_both spec iverilog@13.0 verilator@5.054",
         "# a comment between the sections", "test_gen_v52 spec verilator@5.052",
         "test_gen_none spec", "test_gen_lost spec iverilog@13.0", "test_gen_unrun spec iverilog@13.0"]
CASES = [case("test_gen_both"), case("test_gen_v52"), case("test_gen_none"), case("test_gen_lost"),
         case("test_gen_unrun"), case("test_gen_new"), case("test_gen_unstable", unregistered=("icarus",)),
         case("test_gen_xz", fourstate=True)]


class Record(unittest.TestCase):
    def test_icarus_alone_keeps_the_verilator_tokens_and_the_comments(self):
        ran = {"test_gen_both", "test_gen_v52", "test_gen_none", "test_gen_lost", "test_gen_new",
               "test_gen_unstable"}
        matched = {"test_gen_both", "test_gen_v52", "test_gen_new", "test_gen_unstable"}
        out, notes, changed = ro.record(LINES, CASES, {"icarus": ("iverilog@13.0", ran, matched)})
        self.assertEqual(out, ["# header", "test_gen_both spec iverilog@13.0 verilator@5.054",
                               "# a comment between the sections",
                               "test_gen_v52 spec verilator@5.052 iverilog@13.0",
                               "test_gen_none spec", "test_gen_lost spec",
                               "test_gen_unrun spec iverilog@13.0", "test_gen_new spec iverilog@13.0"])
        self.assertEqual((notes, changed), ([], 3))

    def test_verilator_needs_both_seeds_two_states_and_one_release(self):
        ran = {"test_gen_both", "test_gen_v52", "test_gen_none", "test_gen_xz"}
        matched = {"test_gen_both", "test_gen_v52", "test_gen_none", "test_gen_xz"}
        out, notes, changed = ro.record(LINES, CASES, {"verilator": ("verilator@5.054", ran, matched)})
        self.assertIn("test_gen_none spec verilator@5.054", out)
        self.assertIn("test_gen_v52 spec verilator@5.052", out)
        self.assertNotIn("test_gen_xz", " ".join(out))
        self.assertEqual(changed, 1)
        self.assertEqual(notes, ["test_gen_v52: lists verilator@5.052; verilator@5.054 is not recorded"])

    def test_a_result_of_another_simulator_or_release_is_refused(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "r.json"
            for data, message in (({"simulator": "kirimasim", "version": "kirimasim 0.1"}, "not of icarus"),
                                  ({"simulator": "icarus", "version": "Icarus Verilog version 14.0"},
                                   "not a pinned release")):
                with self.subTest(message=message):
                    path.write_text(json.dumps({**data, "tests": {}}), encoding="utf-8")
                    with self.assertRaisesRegex(ro.Refused, message):
                        ro.load(path, "icarus")
            path.write_text(json.dumps({"simulator": "verilator", "version": "Verilator 5.054 2026-11-01",
                                        "tests": {"ch5/test_x": {"status": "pass"}}}), encoding="utf-8")
            self.assertEqual(ro.load(path, "verilator"), ("verilator@5.054", {}))


if __name__ == "__main__":
    unittest.main()

"""Independent four-state resolution tables and integer bit-plane stimulus."""

from itertools import product
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
import interaction_nettype as cases

TABLES = {"wire": ("0xx0", "x1x1", "xxxx", "01xz"),
          "wand": ("0000", "01x1", "0xxx", "01xz"),
          "wor": ("01x0", "1111", "x1xx", "01xz")}
ALIAS = {"wire": "wire", "tri": "wire", "wand": "wand", "triand": "wand", "wor": "wor", "trior": "wor"}


def table(kind, a, b):
    return TABLES[ALIAS[kind]]["01xz".index(a)]["01xz".index(b)]


def independent_stimulus(width, unknown):
    alphabet = ["0", "1", "x", "z"] if unknown else ["0", "1"]
    n = len(alphabet)
    frames = []
    for phase in range(n*n):
        slow, fast = divmod(phase, n)
        words = []
        for which in range(2):
            planes = [0, 0, 0]  # ones, X and Z masks
            for bit in range(width):
                symbol = alphabet[(fast + bit) % n] if which == 0 else alphabet[(slow + bit // n) % n]
                if symbol != "0":
                    planes[["1", "x", "z"].index(symbol)] |= 1 << bit
            words.append("".join("x" if planes[1] >> bit & 1 else "z" if planes[2] >> bit & 1
                                 else str(planes[0] >> bit & 1) for bit in range(width-1, -1, -1)))
        frames.append(words)
    for frame in range(8):
        code = sum((((bit + 1) // (2**frame)) % 2) << bit for bit in range(width))
        bits = format(code, f"0{width}b")
        frames.append([bits, bits])
    return frames


def interpret(row):
    kind, width, style, override, value, reset = row
    w, lines = int(width), []
    for phase, (a, b) in enumerate(independent_stimulus(w, value == "xz")):
        y = "".join(table(kind if override == "implicit" else "wire", x, z) for x, z in zip(a, b))
        g = table(kind, a[-1], b[-1])
        post = "".join(table("wire", x, z) for x, z in zip(a, b))
        lines += [f"p{phase} input a={a} b={b}", f"p{phase} y={y} inside={y} g={g} ig={g}",
                  f"p{phase} reset={post} inside={post} pg={post[-1]} ipg={post[-1]}",
                  f"p{phase} bits={w},{w},{w},1,{w},1"]
    return "\n".join(lines) + "\n"


class DefaultPortNets(unittest.TestCase):
    def test_all_576_rows_match_independent_table_and_integer_plane_model(self):
        self.assertEqual(len(cases.MODEL.rows()), 576)
        for row in cases.MODEL.rows():
            self.assertEqual(cases.reference(row), interpret(row), row)
        for kind, a, b in product(ALIAS, "01xz", "01xz"):
            self.assertEqual(cases.resolve(kind, a, b), table(kind, a, b))

    def test_selection_keeps_all_targets_and_six_mandatory_cases(self):
        selected = cases.MODEL.select()
        self.assertEqual(len(selected), 40)
        targets = {t for row in selected for t in cases.MODEL.targets(row)}
        self.assertEqual(targets, cases.MODEL.universe())
        self.assertEqual(sum(len(t) == 2 for t in targets), 156)
        self.assertEqual(sum(len(t) == 3 for t in targets), 72)
        self.assertTrue(set(cases.MODEL.anchors) <= set(selected))

    def test_each_bit_sees_every_driver_pair_including_above_64_bits(self):
        for width in (1, 32, 33, 64, 65, 129):
            for unknown in (False, True):
                alphabet = "01xz" if unknown else "01"
                frames = independent_stimulus(width, unknown)[:len(alphabet)**2]
                for position in range(width):
                    self.assertEqual({(a[position], b[position]) for a, b in frames}, set(product(alphabet, repeat=2)))

    def test_index_tags_distinguish_all_129_positions_and_lower_word_reuse(self):
        for unknown in (False, True):
            frames = independent_stimulus(129, unknown)
            tags = frames[-8:]
            self.assertTrue(all(a == b for a, b in tags))
            signatures = {tuple(a[position] for a, _ in tags) for position in range(129)}
            self.assertEqual(len(signatures), 129)
            self.assertNotIn(("0",)*8, signatures)
            # Both truth-table sequences repeat every 16 bits; tag frames
            # must catch corruption that those sequences cannot distinguish.
            repeat = lambda bits: bits[-65:] + bits[-64:]
            self.assertTrue(all(repeat(a) == a for a, _ in frames[:-8]))
            self.assertTrue(any(repeat(a) != a for a, _ in tags))

    def test_explicit_vector_override_does_not_override_scalar_or_later_module(self):
        row = cases.MODEL.anchors[2]
        lines = interpret(row).splitlines()
        phase_one = lines[4:8]
        self.assertIn("g=1 ig=1", phase_one[1])
        self.assertIn("x", phase_one[1].split("y=", 1)[1].split()[0])
        self.assertIn("pg=x ipg=x", phase_one[2])
        self.assertEqual(phase_one[3], "p1 bits=65,65,65,1,65,1")

    def test_reset_forms_preserve_values_but_change_lexical_source(self):
        a = cases.MODEL.anchors[1]
        b = (*a[:-1], "wire")
        self.assertEqual(interpret(a), interpret(b))
        self.assertIn("`resetall", cases.make_case(a).body)
        self.assertNotIn("`resetall", cases.make_case(b).body)

    def test_synonymous_net_keywords_have_equal_semantics_and_distinct_directives(self):
        row = cases.MODEL.anchors[1]
        for left, right in (("wire", "tri"), ("wand", "triand"), ("wor", "trior")):
            a, b = (left, *row[1:]), (right, *row[1:])
            self.assertEqual(interpret(a), interpret(b))
            self.assertIn("`default_nettype " + left, cases.make_case(a).body)
            self.assertIn("`default_nettype " + right, cases.make_case(b).body)

    def test_binary_inputs_still_require_fourstate_due_to_wire_conflicts(self):
        import common
        for row in cases.MODEL.select():
            case = cases.make_case(row)
            common.render(case, cases.NAME, cases.VERSION, cases.CHAPTER, "spec")
            self.assertTrue(case.fourstate)
            self.assertIn("x", case.expected)


if __name__ == "__main__":
    unittest.main()

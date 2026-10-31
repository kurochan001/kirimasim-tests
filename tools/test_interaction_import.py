"""Independent lazy symbol lookup and live value bindings for package port imports."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
import interaction_import as cases


class Scope:
    def __init__(self, explicit=False, local=False):
        self.visible = {"p": "local"} if local else {"p": "package"} if explicit else {}

    def lookup(self, force=False):
        if "p" not in self.visible and force:
            self.visible["p"] = "package"
        return self.visible.get("p")


def interpret(row):
    width, state, value, style, shadow, binding = row
    width = int(width)
    zero, one = [0] * width, [1] * width
    base = [zero, one, [1 - i % 2 for i in range(width)]]
    frames = [("k" + str(i), list(bits)) for i, bits in enumerate(base)]
    if value != "known":
        unknown = 2 if value == "x" else 3
        for i, bits in enumerate(base):
            word = list(bits)
            for pos in {0, width // 2, width - 1}:
                word[pos] = unknown
            frames.append(("u" + str(i), word))
    scope = Scope(style == "explicit", shadow == "local")
    guard = Scope()
    if binding == "zero":
        target = "zero"
    elif binding == "qualified":
        target = "package"
    else:
        target = scope.lookup(force=binding in ("short", "named"))
    self_guard = guard.lookup()  # Reference creation in the other scope cannot leak here.
    assert self_guard is None

    def render(bits):
        return "".join("01xz"[bit] for bit in bits)

    def sample(bits):
        return render([bit if bit < 2 else 0 for bit in bits]) if state == "bit" else render(bits)

    output = []
    for label, package in frames:
        local = [(1, 0, 3, 2)[bit] for bit in package]
        output.append(f"{label} raw={render(package)} package={render(package)} local={render(local)}")
        actual = {"package": package, "local": local, "zero": zero}.get(target)
        left, right = (zero, one) if actual is None else (actual, actual)
        for name, a, b in (("dut", left, right), ("guard", zero, one)):
            output.append(f"{label} {name} left_port={render(a)} left={render(a)} left_sample={sample(a)} "
                          f"right_port={render(b)} right={render(b)} right_sample={sample(b)} bits={width}")
    return "\n".join(output) + "\n"


class PortImportOracle(unittest.TestCase):
    def test_all_540_legal_rows_match_independent_lazy_symbol_lookup(self):
        self.assertEqual(len(cases.MODEL.rows()), 540)
        for row in cases.MODEL.rows():
            self.assertEqual(cases.reference(row), interpret(row), row)

    def test_selection_keeps_all_targets_and_excludes_explicit_local_conflicts(self):
        selected = cases.MODEL.select()
        self.assertEqual(len(selected), 39)
        targets = {t for row in selected for t in cases.MODEL.targets(row)}
        self.assertEqual(targets, cases.MODEL.universe())
        self.assertEqual(sum(len(t) == 2 for t in targets), 158)
        self.assertEqual(sum(len(t) == 3 for t in targets), 141)
        self.assertTrue(set(cases.MODEL.anchors) <= set(selected))
        self.assertFalse(any(row[3] == "explicit" and row[4] == "local" for row in cases.MODEL.rows()))

    def test_star_does_not_force_import_but_short_and_named_connections_do(self):
        base = ("1", "logic", "known", "wild", "none")
        self.assertIn("k0 dut left_port=0 left=0 left_sample=0 right_port=1", cases.reference((*base, "star")))
        for binding in ("short", "named"):
            self.assertIn("k0 dut left_port=0 left=0 left_sample=0 right_port=0", cases.reference((*base, binding)))
        scope, guard = Scope(), Scope()
        self.assertEqual(scope.lookup(force=True), "package")
        self.assertIsNone(guard.lookup())

    def test_local_shadow_wins_and_qualified_connection_bypasses_it(self):
        base = ("1", "logic", "known", "wild", "local")
        self.assertIn("k0 dut left_port=1 left=1 left_sample=1 right_port=1", cases.reference((*base, "star")))
        self.assertIn("k0 dut left_port=0 left=0 left_sample=0 right_port=0", cases.reference((*base, "qualified")))

    def test_two_opposite_defaults_distinguish_every_live_one_bit_source(self):
        for bit in "01xz":
            self.assertNotEqual((bit, bit), ("0", "1"))
        for row in cases.MODEL.select():
            text = cases.reference(row)
            for label, _, _ in cases.phases(row):
                self.assertIn(label + " guard left_port=" + "0" * int(row[0]), text)
                self.assertIn("right_port=" + "1" * int(row[0]), text)

    def test_explicit_zero_suppresses_defaults_and_package_updates_remain_live(self):
        row = ("1", "logic", "known", "explicit", "none", "zero")
        for line in cases.reference(row).splitlines():
            if " dut " in line:
                self.assertIn("left_port=0 left=0 left_sample=0 right_port=0", line)
        row = (*row[:-1], "star")
        self.assertIn("k1 dut left_port=1 left=1 left_sample=1 right_port=1", cases.reference(row))

    def test_final_bit_sample_converts_unknowns_after_four_state_ports(self):
        row = ("1", "bit", "z", "wild", "none", "short")
        self.assertIn("u0 dut left_port=z left=z left_sample=0 right_port=z right=z right_sample=0", cases.reference(row))
        local = ("1", "logic", "x", "wild", "local", "star")
        self.assertIn("u0 dut left_port=z left=z left_sample=z", cases.reference(local))

    def test_rendered_parent_scopes_avoid_accidental_imports_and_implicit_nets(self):
        import common
        for row in cases.MODEL.select():
            case = cases.make_case(row)
            common.render(case, cases.NAME, cases.VERSION, cases.CHAPTER, "spec")
            self.assertTrue(case.body.startswith("`timescale 1ns/1ns\n`default_nettype none"))
            self.assertTrue(case.body.endswith("`default_nettype wire"))
            self.assertIn("input wire", case.body)
            self.assertIn("module port_writer;\n  import port_source::p;", case.body)
            self.assertIn("writer.drive(raw);", case.body)
            guard = "\n".join(cases.parent(row, guard=True))
            self.assertNotIn(".p", guard)
            self.assertNotIn(" p;", guard)
            self.assertNotIn("port_source::p", guard)
            self.assertIn(".FALLBACK('0)", guard)
            self.assertIn(".FALLBACK('1)", guard)


if __name__ == "__main__":
    unittest.main()

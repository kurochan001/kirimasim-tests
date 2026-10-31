"""Independent lexical environments, hierarchy walks and integer-plane casting."""

from dataclasses import dataclass, field
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
import interaction_generate as cases


@dataclass
class Scope:
    parent: object = None
    symbols: dict = field(default_factory=dict)
    imports: object = None

    def lookup(self, name):
        current = self
        while current is not None:
            if name in current.symbols:
                return current.symbols[name]
            if current.imports is not None and name in current.imports.symbols:
                return current.imports.symbols[name]
            current = current.parent
        raise KeyError(name)


def cast_xor(raw, size, state, constant):
    bits = int(raw.replace("x", "0").replace("z", "0"), 2)
    unknown = int("".join("1" if b in "xz" else "0" for b in raw), 2)
    limit = (1 << size) - 1
    bits = (bits ^ (constant & limit)) & limit
    unknown &= limit
    if state == "bit":
        bits &= ~unknown
        unknown = 0
    return "".join("x" if unknown & (1 << i) else str((bits >> i) & 1)
                   for i in range(size-1, -1, -1))


def interpret(row):
    width, state, value, access, shadow, depth, branch = row
    width = int(width)
    package = Scope(symbols={"WIDTH": width, "ORIGIN": 5, "word_t": (width, state)})
    words = ["0" * (width+1), "1" * (width+1),
             "".join(str(1-i%2) for i in range(width+1))]
    output = []
    for unknown in ([False] if value == "known" else [False, True]):
        for phase in range(3):
            label = ("u" if unknown else "k") + str(phase)
            for owner, select in (("a", 0), ("b", 1)):
                raw = list(words[(phase+select) % 3])
                if unknown:
                    for i in {0, (width+1)//2, width}:
                        raw[i] = value
                raw = "".join(raw)
                worker = Scope(symbols={"source": raw, "SELECT": select},
                               imports=package if access == "import" else None)
                lanes = []
                worker.symbols["lanes"] = lanes
                for i in range(2):
                    lane = Scope(parent=worker, symbols={"g": i})
                    lanes.append(lane)
                    container = lane
                    if depth == "two":
                        container = Scope(parent=lane)
                        lane.symbols["layer"] = container
                    selected = (select + i) & 1
                    choice = Scope(parent=container)
                    container.symbols["choice"] = choice
                    has_local = selected == 0 and shadow == "local"
                    if has_local:
                        choice.symbols.update(WIDTH=width+1, ORIGIN=9,
                                              word_t=(width+1, "bit" if state == "logic" else "logic"))
                    namespace = package if access == "qualified" else choice
                    used_width = namespace.lookup("WIDTH")
                    used_origin = namespace.lookup("ORIGIN")
                    type_size, type_state = namespace.lookup("word_t")
                    index = choice.lookup("g")
                    data = choice.lookup("source")
                    choice.symbols.update(kind=selected, local=int(has_local), index=index,
                                          width=used_width, bits=type_size, origin=used_origin,
                                          result=cast_xor(data, type_size, type_state, used_origin+index))
                output.append(f"{label} {owner} source={raw}")
                for i in range(2):
                    # Read through the built hierarchy rather than retaining a leaf reference.
                    scope = worker.symbols["lanes"][i]
                    if depth == "two":
                        scope = scope.symbols["layer"]
                    data = scope.symbols["choice"].symbols
                    output.append(f"{label} {owner} lane={i} kind={data['kind']} local={data['local']} "
                                  f"index={data['index']} width={data['width']} bits={data['bits']} "
                                  f"origin={data['origin']} value={data['result']}")
    return "\n".join(output) + "\n"


class GenerateScopeReference(unittest.TestCase):
    def test_all_legal_rows_match_lexical_lookup_and_hierarchy_interpreter(self):
        self.assertEqual(len(cases.MODEL.rows()), 576)
        for row in cases.MODEL.rows():
            self.assertEqual(cases.reference(row), interpret(row), row)

    def test_selection_keeps_all_pairs_triples_and_anchors(self):
        selected = cases.MODEL.select()
        self.assertEqual(len(selected), 36)
        targets = {t for row in selected for t in cases.MODEL.targets(row)}
        self.assertEqual(targets, cases.MODEL.universe())
        self.assertEqual(sum(len(t) == 2 for t in targets), 148)
        self.assertEqual(sum(len(t) == 3 for t in targets), 68)
        self.assertTrue(set(cases.MODEL.anchors) <= set(selected))

    def test_qualified_package_ignores_existing_local_declarations(self):
        row = cases.MODEL.anchors[2]
        for select in (0, 1):
            for lane in range(2):
                info = cases.leaf(row, select, lane)
                self.assertEqual((info["width"], info["bits"], info["origin"], info["state"]),
                                 (65, 65, 5, "logic"))
        self.assertIn("typedef scope_pkg::word_t used_t;", cases.make_case(row).body)

    def test_imported_local_type_changes_only_the_selected_branch(self):
        row = cases.MODEL.anchors[3]
        for select, lane in ((0, 0), (1, 1)):
            info = cases.leaf(row, select, lane)
            self.assertEqual((info["kind"], info["width"], info["origin"], info["state"]),
                             (0, 34, 9, "logic"))
            self.assertEqual(cases.value(row, "z" * 34, select, lane), "x" * 34)
        for select, lane in ((0, 1), (1, 0)):
            info = cases.leaf(row, select, lane)
            self.assertEqual((info["kind"], info["width"], info["origin"], info["state"]),
                             (1, 33, 5, "bit"))
            self.assertEqual(cases.value(row, "z" * 34, select, lane), "0" * 33)

    def test_bit_conversion_occurs_after_logic_xor_not_before_it(self):
        row = ("1", "bit", "x", "qualified", "none", "one", "if")
        # Source X XOR known 1 is X, then becomes 0 in a bit destination.
        self.assertEqual(cases.value(row, "0x", 0, 0), "0")
        self.assertEqual(cast_xor("0x", 1, "bit", 1), "0")

    def test_branch_form_and_depth_change_paths_but_not_observations(self):
        row = cases.MODEL.anchors[1]
        for depth in ("one", "two"):
            for branch in ("if", "case"):
                other = (*row[:5], depth, branch)
                self.assertEqual(cases.reference(row), cases.reference(other))
                self.assertEqual(".layer." in cases.path(other, "a", 0), depth == "two")

    def test_selected_sources_render_and_keep_known_controls_with_unknowns(self):
        import common
        for row in cases.MODEL.select():
            case = cases.make_case(row)
            common.render(case, cases.NAME, cases.VERSION, cases.CHAPTER, "spec")
            self.assertEqual(len(cases.phases(row)), 3 if row[2] == "known" else 6)
            self.assertIn("localparam int INDEX = g;", case.body)
            self.assertIn("assign value = source ^", case.body)


if __name__ == "__main__":
    unittest.main()

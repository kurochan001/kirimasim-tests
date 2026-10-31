"""Independent binding table and delayed thunks for callee-scoped defaults."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
import interaction_default as cases


def interpret(row):
    width, state, value, home, expression, passing = row
    width = int(width)
    words = ["0" * width, "1" * width, "".join(str(1-i%2) for i in range(width))]
    output = []
    for unknown in ([False] if value == "known" else [False, True]):
        for phase in range(3):
            label = ("u" if unknown else "k") + str(phase)
            instances = {o: dict(source=words[0], mask_source=words[0], calls=0,
                                 data_reads=0, mask_reads=0) for o in ("a", "b")}
            for index, owner in enumerate(("a", "b", "a")):
                instance = instances[owner]
                start = (phase + index + int(owner == "b")) % 3
                d, m = list(words[start]), list(words[(start+1) % 3])
                if unknown:
                    for i in {0, width//2, width-1}:
                        d[i] = value
                    m[(width-1)//3] = value
                if state == "bit":
                    d = ["0" if b in "xz" else b for b in d]
                    m = ["0" if b in "xz" else b for b in m]
                instance["source"], instance["mask_source"] = "".join(d), "".join(m)
                caller = {"data": "".join("0" if b == "1" else "1" for b in d),
                          "mask": "".join("0" if b == "1" else "1" for b in m)}

                def data_default():
                    if expression == "function":
                        instance["data_reads"] += 1
                    return instance["source"]

                def mask_default():
                    if expression == "function":
                        instance["mask_reads"] += 1
                    return instance["mask_source"]

                # Formal-to-actual binding is built independently of the generator's flags.
                actuals = {}
                if passing == "empty_data":
                    actuals["mask"] = caller["mask"]
                elif passing == "named_data":
                    actuals["data"] = caller["data"]
                elif passing == "explicit_zero":
                    actuals.update(data=words[0], mask=words[0])
                elif passing == "named_both":
                    actuals.update(mask=caller["mask"], data=caller["data"])
                data = actuals["data"] if "data" in actuals else data_default()
                mask = actuals["mask"] if "mask" in actuals else mask_default()
                unknown_bits = int("".join("1" if x in "xz" or y in "xz" else "0"
                                           for x, y in zip(data, mask)), 2)
                a = int(data.replace("x", "0").replace("z", "0"), 2)
                b = int(mask.replace("x", "0").replace("z", "0"), 2)
                answer = "".join("x" if unknown_bits & (1 << i) else str(((a ^ b) >> i) & 1)
                                 for i in range(width-1, -1, -1))
                instance["calls"] += 1
                output.append(f"{label} call={index} owner={owner} return={answer} data={data} mask={mask}")
                for o, s in instances.items():
                    output.append(f"{label} {o} calls={s['calls']} data_reads={s['data_reads']} "
                                  f"mask_reads={s['mask_reads']} source={s['source']} mask_source={s['mask_source']}")
                output.append(f"{label} caller data_reads=0 mask_reads=0 "
                              f"source={caller['data']} mask_source={caller['mask']}")
    return "\n".join(output) + "\n"


class DefaultArgumentReference(unittest.TestCase):
    def test_all_legal_rows_match_independent_thunk_binding_interpreter(self):
        self.assertEqual(len(cases.MODEL.rows()), 720)
        for row in cases.MODEL.rows():
            self.assertEqual(cases.reference(row), interpret(row), row)

    def test_selection_keeps_all_pairs_triples_and_mandatory_witnesses(self):
        selected = cases.MODEL.select()
        self.assertEqual(len(selected), 36)
        targets = {t for row in selected for t in cases.MODEL.targets(row)}
        self.assertEqual(targets, cases.MODEL.universe())
        self.assertEqual(sum(len(t) == 2 for t in targets), 159)
        self.assertEqual(sum(len(t) == 3 for t in targets), 128)
        self.assertTrue(set(cases.MODEL.anchors) <= set(selected))

    def test_explicit_zero_suppresses_both_default_getters(self):
        row = cases.MODEL.anchors[4]
        text = cases.reference(row)
        self.assertIn("k0 a calls=2 data_reads=0 mask_reads=0", text)
        for line in text.splitlines():
            if " return=" in line:
                self.assertIn("return=" + "0"*32 + " data=" + "0"*32 + " mask=" + "0"*32, line)

    def test_empty_data_and_named_data_select_opposite_default_subsets(self):
        base = ("1", "logic", "known", "interface", "function")
        empty = cases.reference((*base, "empty_data"))
        named = cases.reference((*base, "named_data"))
        self.assertIn("k0 a calls=2 data_reads=2 mask_reads=0", empty)
        self.assertIn("k0 a calls=2 data_reads=0 mask_reads=2", named)
        self.assertIn("caller data_reads=0 mask_reads=0", empty)

    def test_repeated_calls_use_new_declaring_instance_values(self):
        row = ("1", "bit", "known", "module", "function", "omitted")
        text = cases.reference(row)
        self.assertIn("k0 call=0 owner=a return=1 data=0 mask=1", text)
        self.assertIn("k0 call=2 owner=a return=1 data=1 mask=0", text)
        self.assertIn("k0 a calls=2 data_reads=2 mask_reads=2", text)
        self.assertIn("k0 b calls=1 data_reads=1 mask_reads=1", text)

    def test_formal_observations_prevent_xor_cancellation_hiding_wrong_scope(self):
        row = cases.MODEL.anchors[0]
        self.assertIn("k0 call=0 owner=a return=1 data=0 mask=1", cases.reference(row))
        self.assertIn("k0 caller data_reads=0 mask_reads=0 source=1 mask_source=0", cases.reference(row))
        self.assertEqual(cases.xor("0", "1"), cases.xor("1", "0"))
        self.assertNotEqual(("0", "1"), ("1", "0"))

    def test_named_order_and_scope_forms_render_with_known_controls(self):
        import common
        for row in cases.MODEL.select():
            case = cases.make_case(row)
            common.render(case, cases.NAME, cases.VERSION, cases.CHAPTER, "spec")
            self.assertEqual(len(cases.phases(row)), 3 if row[2] == "known" else 6)
            self.assertIn(row[3] + " default_worker", case.body)
            self.assertIn("return data_arg ^ mask_arg;", case.body)
        self.assertEqual(cases.call_expression("named_both", "a"),
                         "a.pick(.mask_arg(mask_source), .data_arg(source))")


if __name__ == "__main__":
    unittest.main()

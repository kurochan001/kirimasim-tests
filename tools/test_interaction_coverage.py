"""Check legal covering sets and reject false execution-coverage evidence."""

from copy import deepcopy
import datetime
from itertools import product
from pathlib import Path
import sys
import unittest

import interaction_coverage as coverage
import suite_results

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
from interaction_cover import Model
from interaction_models import SuiteModel
import interaction_nba
import interaction_expr
import interaction_select
import interaction_cond
import interaction_models


class CoveringSets(unittest.TestCase):
    def test_registered_models_have_all_projected_targets_and_available_anchors(self):
        for plan in interaction_models.registered():
            with self.subTest(model=plan.model.name):
                selected = plan.model.select()
                self.assertTrue(set(selected) <= set(plan.available))
                self.assertTrue(set(plan.model.anchors) <= set(selected))
                self.assertEqual({t for r in selected for t in plan.model.targets(r)},
                                 set(plan.model.universe()))
                self.assertEqual(selected, plan.model.select())

    def test_legal_projection_needs_a_complete_extension(self):
        model = Model("extend", (("a", ("0", "1")), ("b", ("0", "1")),
                                  ("c", ("0", "1"))),
                      lambda r: r[0] == r[2] and r[1] != r[2])
        self.assertEqual(set(model.rows()), {("0", "1", "0"), ("1", "0", "1")})
        self.assertNotIn(((0, "0"), (1, "0")), model.universe())
        with self.assertRaisesRegex(ValueError, "legal complete"):
            model.targets(("0", "0", "1"))
        self.assertEqual({t for r in model.select() for t in model.targets(r)},
                         set(model.universe()))

    def test_pairwise_does_not_imply_a_three_factor_interaction(self):
        factors = tuple((n, ("0", "1")) for n in ("a", "b", "c"))
        even = (("0", "0", "0"), ("0", "1", "1"), ("1", "0", "1"), ("1", "1", "0"))
        pair = Model("pair", factors, lambda r: True)
        triple = Model("triple", factors, lambda r: True, groups=(("a", "b", "c"),))
        self.assertEqual({t for r in even for t in pair.targets(r)}, set(pair.universe()))
        self.assertLess(len({t for r in even for t in triple.targets(r)}), len(triple.universe()))
        self.assertEqual(set(triple.select()), set(product(("0", "1"), repeat=3)))

    def test_anchors_survive_pruning_and_selection_is_deterministic(self):
        m = interaction_nba.MODEL
        selected = m.select()
        self.assertEqual(selected, m.select())
        self.assertTrue(set(m.anchors) <= set(selected))
        self.assertEqual({t for r in selected for t in m.targets(r)}, set(m.universe()))
        self.assertLess(len(selected), len(m.rows()))
        # Every required width/state/value triple needs a witness row.
        triples = {tuple(r[i] for i in (0, 1, 2)) for r in m.rows()}
        self.assertGreaterEqual(len(selected), len(triples))

    def test_invalid_and_explosive_models_fail_closed(self):
        with self.assertRaisesRegex(ValueError, "enumeration limit"):
            Model("huge", tuple((str(i), ("0", "1")) for i in range(20)), lambda r: True)
        empty = Model("empty", (("a", ("0",)), ("b", ("0",))), lambda r: False)
        bad = Model("bad", (("a", ("0",)), ("b", ("0",))), lambda r: True,
                    anchors=(("1", "1"),))
        for _ in range(2):
            with self.assertRaisesRegex(ValueError, "no legal"):
                empty.select()
            with self.assertRaisesRegex(ValueError, "mandatory witness"):
                bad.select()
        with self.assertRaisesRegex(ValueError, "distinct factors"):
            Model("bad", (("a", ("0",)), ("a", ("0",))), lambda r: True)

    def test_nba_oracle_preserves_z_and_converts_unknowns_before_capture(self):
        base = ("65", "logic", "z", "array", "descending", "task", "delayed")
        self.assertEqual(interaction_nba.reference(base), ("0" * 65, "z" * 65, "1" * 65))
        bit = ("65", "bit", "x", "array", "ascending", "initial", "immediate")
        self.assertEqual(interaction_nba.reference(bit), ("1" * 65, "0" * 65, "1" * 65))

    def test_arithmetic_context_keeps_carry_and_changes_mixed_sign_extension(self):
        unsigned = ("32", "same", "wide", "unsigned", "unsigned", "mul")
        self.assertEqual(interaction_expr.reference(unsigned, 0xffffffff, 2), 0x1fffffffe)
        signed = ("33", "narrow", "wide", "signed", "signed", "add")
        mixed = ("33", "narrow", "wide", "signed", "unsigned", "add")
        self.assertEqual(interaction_expr.reference(signed, 0x100000000, 0x80000000),
                         0x280000000)
        self.assertEqual(interaction_expr.reference(mixed, 0x100000000, 0x80000000),
                         0x180000000)
        with self.assertRaisesRegex(ValueError, "legal complete"):
            interaction_expr.MODEL.targets(("1", "narrow", "same", "signed", "signed", "add"))

    def test_packed_slice_preserves_neighbors_and_known_writes_always_change_data(self):
        for row in interaction_select.MODEL.rows():
            before, data, old_slice, after = interaction_select.reference(row)
            w, size, offset = interaction_select.geometry(row)
            start = w - offset - size
            self.assertEqual(before[:start], after[:start])
            self.assertEqual(before[start + size:], after[start + size:])
            if row[6] == "known":
                self.assertNotEqual(data, old_slice)
                self.assertNotEqual(before, after)
        row = ("33", "descending", "plus", "half", "interior", "logic", "z")
        before, data, _, after = interaction_select.reference(row)
        self.assertEqual(data, "z" * 16)
        self.assertEqual(after, before[:9] + "z" * 16 + before[25:])
        with self.assertRaisesRegex(ValueError, "legal complete"):
            interaction_select.MODEL.targets(("1", "ascending", "plus", "half", "low", "bit", "x"))

    def test_conditional_merge_distinguishes_known_selection_from_z_z_merge(self):
        ambiguous = ("1", "signed", "signed", "x", "same_xz", "wide", "logic")
        known = ("1", "signed", "signed", "1", "same_xz", "wide", "logic")
        mixed = ("1", "signed", "unsigned", "1", "same_xz", "wide", "logic")
        bit = ("1", "signed", "unsigned", "1", "same_xz", "wide", "bit")
        self.assertEqual(interaction_cond.reference(ambiguous), ("z", "z", "xx"))
        self.assertEqual(interaction_cond.reference(known), ("z", "z", "zz"))
        self.assertEqual(interaction_cond.reference(mixed), ("z", "z", "0z"))
        self.assertEqual(interaction_cond.reference(bit), ("z", "z", "00"))


class ExecutionEvidence(unittest.TestCase):
    def setUp(self):
        m = Model("tiny", (("a", ("0", "1")), ("b", ("0", "1"))), lambda r: True,
                  anchors=(("1", "1"),))
        self.plan = SuiteModel(m, lambda r: "tests/ch10/test_fake_" + "".join(r) + ".sv",
                               m.rows(), "a fixture with observed output")
        self.digests = {self.plan.path(r): "current-" + "".join(r) for r in m.rows()}
        self.run = {"simulator": "icarus", "version": "test version",
                    "generated_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
                    "runner_sha256": suite_results.runner_digest("icarus"), "runner_changed": False,
                    "tests": {suite_results.test_id(coverage.ROOT / p):
                              {"status": "pass", "inputs_sha256": digest}
                              for p, digest in self.digests.items()}}

    def evaluate(self, run=None):
        return coverage.evaluate(self.plan, run or self.run, self.digests)

    def test_current_complete_run_qualifies(self):
        result = self.evaluate()
        self.assertTrue(result["complete"])
        self.assertEqual(result["coverage"]["2"], {"passed": 4, "total": 4, "missing": 0})

    def test_fail_known_unsupported_and_missing_do_not_qualify(self):
        for status in ("fail", "known", "unsupported", None):
            with self.subTest(status=status):
                r = deepcopy(self.run)
                key = next(iter(r["tests"]))
                if status is None:
                    del r["tests"][key]
                else:
                    r["tests"][key]["status"] = status
                result = self.evaluate(r)
                self.assertFalse(result["complete"])
                self.assertEqual(result["coverage"]["2"]["passed"], 3)

    def test_stale_inputs_and_changed_runner_reject_pass_receipts(self):
        for kind in ("input", "input_changed", "runner", "runner_changed", "time"):
            with self.subTest(kind=kind):
                r = deepcopy(self.run)
                entry = next(iter(r["tests"].values()))
                if kind == "input": entry["inputs_sha256"] = "old"
                elif kind == "input_changed": entry["inputs_changed"] = True
                elif kind == "runner": r["runner_sha256"] = "old"
                elif kind == "runner_changed": r["runner_changed"] = True
                else: del r["generated_at"]
                self.assertFalse(self.evaluate(r)["complete"])
                self.assertGreater(self.evaluate(r)["case_statuses"]["stale"], 0)

    def test_partial_successes_are_not_merged_between_runs(self):
        left, right = deepcopy(self.run), deepcopy(self.run)
        keys = list(left["tests"])
        del left["tests"][keys[0]]
        del right["tests"][keys[1]]
        self.assertFalse(self.evaluate(left)["complete"])
        self.assertFalse(self.evaluate(right)["complete"])

    def test_anchor_requires_its_own_pass(self):
        # Three binary factors need only four pairwise rows. Remove one
        # explicit anchor but keep all other rows: projections still pass.
        m = Model("anchor", tuple((n, ("0", "1")) for n in ("a", "b", "c")),
                  lambda r: True, anchors=(("1", "1", "1"),))
        p = SuiteModel(m, lambda r: "tests/ch10/test_" + "".join(r) + ".sv", m.rows(), "fixture")
        digests = {p.path(r): "hash" for r in m.rows()}
        run = deepcopy(self.run)
        run["tests"] = {suite_results.test_id(coverage.ROOT / path):
                        {"status": "pass", "inputs_sha256": "hash"} for path in digests}
        del run["tests"][suite_results.test_id(coverage.ROOT / p.path(m.anchors[0]))]
        result = coverage.evaluate(p, run, digests)
        self.assertEqual(result["coverage"]["2"]["missing"], 0)
        self.assertFalse(result["complete"])

    def test_malformed_snapshot_is_rejected(self):
        with self.assertRaises(ValueError): coverage.run_problem([])
        with self.assertRaises(ValueError): coverage.run_problem({"simulator": "unknown"})


if __name__ == "__main__":
    unittest.main()

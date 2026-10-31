"""Check legal covering sets and reject false execution-coverage evidence."""

from copy import deepcopy
import datetime
import json
from itertools import product
from pathlib import Path
import sys
import tempfile
import unittest
from unittest import mock

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
import interaction_shift
import interaction_cast
import interaction_task
import interaction_struct
import interaction_case
import interaction_port
import interaction_array
import interaction_query
import interaction_stream
import interaction_compare
import interaction_method
import interaction_index
import interaction_queue
import interaction_divide
import interaction_resize
import interaction_concat
import interaction_logic
import interaction_shortcircuit
import interaction_edge
from interaction_bits import resize


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

    def test_shift_uses_context_width_and_preserves_a_z_sign_bit(self):
        wider = ("33", "signed", "shr", "width", "known", "wide", "logic")
        self.assertEqual(interaction_shift.reference(wider)[2], "0" * 33 + "1")
        zsign = ("65", "signed", "ashr", "width", "z", "wide", "logic")
        self.assertEqual(interaction_shift.reference(zsign)[2], "z" * 66)
        unknown = ("32", "unsigned", "shl", "z", "known", "same", "logic")
        bit = (*unknown[:-1], "bit")
        self.assertEqual(interaction_shift.reference(unknown)[2], "x" * 32)
        self.assertEqual(interaction_shift.reference(bit)[2], "0" * 32)
        with self.assertRaisesRegex(ValueError, "legal complete"):
            interaction_shift.MODEL.targets(("1", "signed", "shr", "last", "x", "same", "logic"))

    def test_cast_converts_before_arithmetic_and_size_cast_limits_context(self):
        bit_cast = ("1", "unsigned", "x", "typed_bit", "same", "add", "logic")
        logic_cast = ("1", "unsigned", "x", "typed_logic", "same", "add", "logic")
        self.assertEqual(interaction_cast.reference(bit_cast), ("x", "0", "001"))
        self.assertEqual(interaction_cast.reference(logic_cast), ("x", "x", "xxx"))
        signed = ("1", "unsigned", "known", "signed", "same", "plain", "logic")
        unsigned = ("1", "signed", "known", "unsigned", "same", "plain", "logic")
        self.assertEqual(interaction_cast.reference(signed)[2], "111")
        self.assertEqual(interaction_cast.reference(unsigned)[2], "001")
        narrow = ("33", "signed", "known", "size", "narrow", "add", "bit")
        self.assertEqual(int(interaction_cast.reference(narrow)[2], 2), 0x10002)
        with self.assertRaisesRegex(ValueError, "positive width"):
            resize("1", 0, False)

    def test_task_modes_differ_inside_and_after_return(self):
        for mode in ("input", "output", "inout", "ref"):
            with self.subTest(mode=mode):
                row = ("1", "logic", "z", mode, "element", "delayed")
                source, before, captured, inside, after = interaction_task.reference(row)
                self.assertEqual((source, before, captured), ("z", "0", "z"))
                self.assertEqual(inside, "z" if mode == "ref" else "0")
                self.assertEqual(after, "0" if mode == "input" else "z")
        bit = ("1", "bit", "x", "output", "scalar", "delayed")
        self.assertEqual(interaction_task.reference(bit), ("x", "1", "0", "1", "0"))

    def test_packed_structure_member_and_aggregate_extend_independently(self):
        row = ("1", "first", "signed", "unsigned", "logic", "z", "whole", "nba")
        self.assertEqual(interaction_struct.reference(row),
                         ("z", "0", "0101", "z101", "0000z", "zz101"))
        row = ("1", "last", "unsigned", "signed", "logic", "x", "member", "blocking")
        self.assertEqual(interaction_struct.reference(row),
                         ("x", "0", "101x", "101x", "xxxxx", "0101x"))

    def test_case_masks_both_sides_and_preserves_first_match_priority(self):
        m = interaction_case.matches
        self.assertTrue(m("x", "x", False, "case"))
        self.assertFalse(m("x", "0", False, "casez"))
        self.assertTrue(m("z", "0", False, "casez"))
        self.assertTrue(m("0", "z", False, "casez"))
        self.assertTrue(m("x", "0", False, "casex"))
        self.assertTrue(m("1", "11", True, "case"))
        self.assertFalse(m("1", "11", False, "case"))
        fallback = ("1", "unsigned", "unsigned", "same", "case", "known", "flip_low")
        self.assertEqual(interaction_case.reference(fallback), ("1", "0", "1", 9, 2))
        mixed = ("1", "signed", "unsigned", "wide", "case", "known", "equal")
        self.assertEqual(interaction_case.reference(mixed), ("1", "11", "11", 9, 9))

    def test_port_source_sign_is_used_before_sampling_state_conversion(self):
        signed = ("1", "input", "signed", "wide", "z", "logic", "named", "ansi")
        unsigned = ("1", "output", "unsigned", "wide", "z", "bit", "positional", "nonansi")
        self.assertEqual(interaction_port.reference(signed), ("z", "zz", "zz"))
        self.assertEqual(interaction_port.reference(unsigned), ("z", "0z", "00"))
        for row in interaction_port.MODEL.anchors:
            self.assertIn(row, interaction_port.MODEL.select())

    def test_array_rotations_distinguish_one_bit_positions_and_keep_slice_guard(self):
        row = ("1", "signed", "bit", "descending", "ascending", "x", "whole")
        a, ea, changed0 = interaction_array.reference(row, 0)
        b, eb, changed1 = interaction_array.reference(row, 1)
        self.assertEqual(a, ["0", "0", "1"])
        self.assertEqual(b, ["1", "0", "0"])
        self.assertEqual(len(set(zip(a, b))), 3)
        self.assertEqual((ea, eb), (["00", "00", "11"], ["11", "00", "00"]))
        self.assertEqual((changed0, changed1), ("1", "0"))
        sliced = (*row[:-1], "slice")
        self.assertEqual(interaction_array.reference(sliced, 1)[0], ["1", "0", "1"])

    def test_queries_deduplicate_controls_and_count_known_ones_with_unknowns(self):
        mixed = ("129", "logic", "repeat", "mixed", "middle", "duplicate")
        source, expr, result = interaction_query.reference(mixed)
        self.assertEqual(result, (258, 6, 2, 0, 0, 1))
        self.assertEqual(interaction_query.reference((*mixed[:-1], "mixed"))[2], result)
        unknown = ("65", "logic", "direct", "x", "high", "unknown")
        self.assertEqual(interaction_query.reference(unknown)[2], (65, 1, 1, 1, 1, 1))
        dropped = ("33", "bit", "half", "one", "high", "one")
        self.assertEqual(interaction_query.reference(dropped)[2], (16, 0, 0, 0, 1, 0))

    def test_fixed_oracle_registration_rejects_inconsistent_qualification_runs(self):
        directory = coverage.ROOT / "coverage/interaction-qualification/20261029-query"
        snapshots = [json.loads(p.read_text()) for p in sorted(directory.glob("*.json"))]
        self.assertEqual(len(snapshots), 6)
        oracles = coverage.common.read_oracles()
        unstable = set()
        for case in interaction_query.cases():
            key = "gen/ch20/" + case.name
            self.assertTrue(all("13.0" in r["version"] and key in r["tests"] for r in snapshots))
            if any(r["tests"][key]["status"] != "pass" for r in snapshots):
                unstable.add(case.name)
                self.assertNotIn("iverilog@13.0", oracles.get(case.name, "").split())
        self.assertEqual(len(unstable), 9)
        linux_log = (directory.parent / "20261029-query-linux-check.log").read_text()
        linux_failed = {line.split()[1].removeprefix("tests/gen/ch20/").removesuffix(".sv:")
                        for line in linux_log.splitlines() if line.startswith("FAIL ")}
        self.assertEqual(len(linux_failed), 12)
        self.assertFalse(unstable & linux_failed)
        for name in linux_failed:
            self.assertNotIn("iverilog@13.0", oracles.get(name, "").split())
        unstable |= linux_failed
        self.assertEqual(unstable, {interaction_query.case_name(r)
                                   for r in interaction_query.MODEL.select()
                                   if interaction_query.icarus_unstable(r)})

    def test_comparison_oracle_distinguishes_signedness_unknowns_and_wildcard_side(self):
        compare = interaction_compare.compare
        self.assertEqual(compare("1111", "00001111", "signed", "unsigned", "eq"), "1")
        self.assertEqual(compare("1111", "00001111", "signed", "signed", "eq"), "0")
        self.assertEqual(compare("1111", "00001111", "signed", "signed", "lt"), "1")
        self.assertEqual(compare("1x00", "0100", "unsigned", "unsigned", "eq"), "0")
        self.assertEqual(compare("1x00", "1100", "unsigned", "unsigned", "eq"), "x")
        self.assertEqual(compare("1x00", "0100", "unsigned", "unsigned", "gt"), "x")
        self.assertEqual(compare("1x01", "1101", "unsigned", "unsigned", "weq"), "x")
        self.assertEqual(compare("1001", "1x01", "unsigned", "unsigned", "weq"), "1")
        self.assertEqual(compare("z001", "z001", "signed", "signed", "ceq"), "1")
        self.assertEqual(compare("x001", "z001", "signed", "signed", "cne"), "1")

    def test_array_method_overflow_happens_before_destination_extension(self):
        row = ("1", "logic", "unsigned", "queue", "sum", "plain", "known")
        self.assertEqual(interaction_method.reference(row, 0), ("1", "01"))
        self.assertEqual(interaction_method.reference((*row[:5], "widen", row[-1]), 0),
                         ("11", "011"))
        signed = ("1", "logic", "signed", "fixed", "sum", "plain", "known")
        self.assertEqual(interaction_method.reference(signed, 0), ("1", "11"))
        self.assertEqual(interaction_method.reference((*signed[:5], "widen", signed[-1]), 0),
                         ("01", "001"))

    def test_array_method_cast_truncation_and_four_state_controlling_values(self):
        row = ("129", "logic", "signed", "queue", "xor", "integer", "high_z")
        self.assertEqual(interaction_method.reference(row, 0), ("0" * 31 + "1", "0" * 32 + "1"))
        plain = (*row[:5], "plain", row[-1])
        self.assertEqual(interaction_method.reference(plain, 0)[0][0], "x")
        unknown_or = ("1", "logic", "unsigned", "fixed", "or", "integer", "high_x")
        self.assertEqual(interaction_method.reference(unknown_or, 1),
                         ("0" * 31 + "x", "0" * 32 + "x"))
        converted_or = (*unknown_or[:5], "int", unknown_or[-1])
        self.assertEqual(interaction_method.reference(converted_or, 1), ("0" * 32, "0" * 33))
        reduce = interaction_method.reduce_values
        self.assertEqual(reduce(["xz", "00", "11"], "and"), "00")
        self.assertEqual(reduce(["xz", "00", "11"], "or"), "11")
        self.assertEqual(reduce(["xz", "00", "11"], "xor"), "xx")

    def test_variable_indices_keep_their_sign_and_invalid_access_defaults(self):
        row = ("33", "negative", "ascending", "logic", "signed", "low", "known")
        self.assertEqual(interaction_index.position(row), 0)
        initial, before, incoming, after, read = interaction_index.reference(row)
        self.assertEqual((before, incoming, read), ("1", "0", "0"))
        self.assertEqual(after, "0" + initial[1:])
        unsigned = (*row[:4], "unsigned", *row[5:])
        self.assertEqual(interaction_index.index_bits(row), interaction_index.index_bits(unsigned))
        self.assertIsNone(interaction_index.position(unsigned))
        self.assertEqual(interaction_index.reference(unsigned)[1:], ("x", "0", initial, "x"))
        unknown = ("65", "offset", "descending", "bit", "signed", "z", "x")
        source, before, _, result, after = interaction_index.reference(unknown)
        self.assertEqual((before, after), ("0", "0"))
        self.assertEqual(source, result)

    def test_queue_overflow_drops_the_tail_after_insertion_and_keeps_the_copy(self):
        row = ("1", "bit", "unsigned", "three", "3", "push_front", "known")
        saved, result, _, changed, removed = interaction_queue.reference(row, 0)
        self.assertEqual(saved, ["1", "0", "1"])
        self.assertEqual(result, ["1", "1", "0"])
        self.assertEqual((changed, removed), ("00", "00"))
        push_back = (*row[:5], "push_back", row[-1])
        self.assertEqual(interaction_queue.reference(push_back, 0)[1], saved)
        write_end = (*row[:5], "write_end", row[-1])
        self.assertEqual(interaction_queue.reference(write_end, 0)[1], saved)
        phases = [interaction_queue.reference(row, p)[0] for p in (0, 1)]
        self.assertEqual(len(set(zip(*phases))), 3)
        self.assertIn("expected_stderr_regex", interaction_queue.make_case(row).extra)

    def test_queue_empty_pops_and_argument_conversion_use_element_type(self):
        row = ("33", "logic", "signed", "unbounded", "0", "pop_back", "known")
        self.assertEqual(interaction_queue.reference(row, 0)[-1], "x" * 34)
        unsigned = (row[0], row[1], "unsigned", *row[3:])
        self.assertEqual(interaction_queue.reference(unsigned, 0)[-1], "0" + "x" * 33)
        binary = (row[0], "bit", *row[2:])
        self.assertEqual(interaction_queue.reference(binary, 0)[-1], "0" * 34)
        self.assertTrue(interaction_queue.make_case(row).fourstate)
        self.assertFalse(interaction_queue.make_case(binary).fourstate)
        insert = ("1", "bit", "unsigned", "two", "2", "insert", "z")
        saved, result, source, changed, _ = interaction_queue.reference(insert, 0)
        self.assertEqual((saved, result, source, changed), (["0", "1"], ["0", "0"], "zz", "01"))

    def test_division_rounds_toward_zero_and_remainder_follows_the_numerator(self):
        divide = interaction_divide.quotient_remainder
        self.assertEqual(divide(-7, 3), (-2, -1))
        self.assertEqual(divide(7, -3), (-2, 1))
        self.assertEqual(divide(-7, -3), (2, -1))
        row = ("1", "same", "wide", "signed", "signed", "div", "known", "logic")
        a, b = interaction_divide.inputs(row, 0)
        self.assertEqual((a, b), ("1", "1"))
        self.assertEqual(interaction_divide.reference(row, a, b, 1), "1")
        self.assertEqual(interaction_divide.reference(row, a, b, 2), "01")
        signed = ("32", "same", "same", "signed", "signed", "mod", "known", "logic")
        a, b = interaction_divide.inputs(signed, 1)
        self.assertEqual(interaction_divide.reference(signed, a, b, 32), "1" * 32)
        mixed = (*signed[:4], "unsigned", *signed[5:])
        self.assertEqual(interaction_divide.reference(mixed, a, b, 32), "0" * 32)

    def test_division_keeps_known_witnesses_before_unknown_and_zero_divisors(self):
        row = ("32", "same", "wide", "signed", "signed", "div", "zero", "bit")
        case = interaction_divide.make_case(row)
        self.assertTrue(case.fourstate)
        self.assertIn("k0_result=", case.expected)
        self.assertIn("p0_result=" + "x" * 32 + " direct=" + "0" * 33, case.expected)
        unknown = (*row[:6], "rhs_z", "logic")
        a, b = interaction_divide.inputs(unknown, 1)
        self.assertEqual(interaction_divide.reference(unknown, a, b, 33), "x" * 33)

    def test_dynamic_resize_preserves_prefix_and_uses_element_defaults(self):
        row = ("1", "logic", "signed", "z", "3", "4", "self")
        initial, result, peer, modified = interaction_resize.reference(row, 0)
        self.assertEqual(initial, ["z", "0", "1"])
        self.assertEqual(result, ["z", "0", "1", "x"])
        self.assertEqual(peer, ["1", "0", "1"])
        self.assertEqual(modified, ["1", "0", "1", "x"])
        short = (*row[:5], "1", "copy")
        self.assertEqual(interaction_resize.reference(short, 1)[1], ["0"])
        bit = ("1", "bit", "signed", "z", "3", "4", "self")
        self.assertEqual(interaction_resize.reference(bit, 0)[1], ["0", "0", "1", "0"])
        phases = [interaction_resize.reference(row, p)[0] for p in (0, 1)]
        self.assertEqual(len(set(zip(*phases))), 3)

    def test_dynamic_resize_reset_and_padding_require_four_state_evidence(self):
        reset = ("33", "logic", "signed", "known", "2", "2", "reset")
        self.assertEqual(interaction_resize.reference(reset, 0)[1], ["x" * 33] * 2)
        self.assertTrue(interaction_resize.make_case(reset).fourstate)
        empty_source = ("1", "logic", "unsigned", "known", "0", "4", "self")
        self.assertEqual(interaction_resize.reference(empty_source, 0)[1], ["x"] * 4)
        self.assertTrue(interaction_resize.make_case(empty_source).fourstate)
        empty_result = (*reset[:5], "0", "reset")
        self.assertEqual(interaction_resize.reference(empty_result, 0)[1], [])
        self.assertFalse(interaction_resize.make_case(empty_result).fourstate)

    def test_concatenated_assignment_extends_rhs_before_partitioning(self):
        row = ("2", "head_bit", "narrow", "signed", "ll", "unsigned", "blocking", "known")
        self.assertEqual(interaction_concat.reference(row, 0)[:4], ("1", "11", "1", "1"))
        unsigned = (*row[:3], "unsigned", *row[4:])
        self.assertEqual(interaction_concat.reference(unsigned, 0)[:4], ("1", "01", "0", "1"))
        signed_members = (*row[:5], "signed", *row[6:])
        self.assertIn("p0_wide=11 11 concat=011", interaction_concat.make_case(signed_members).expected)
        self.assertIn("p0_wide=01 01 concat=011", interaction_concat.make_case(row).expected)

    def test_concatenated_assignment_converts_each_field_and_captures_nba(self):
        row = ("2", "head_bit", "narrow", "signed", "bl", "signed", "nba", "x")
        self.assertEqual(interaction_concat.reference(row, 0),
                         ("x", "xx", "0", "x", "1", "1", "1"))
        case = interaction_concat.make_case(row)
        self.assertTrue(case.fourstate)
        self.assertIn("p0_scheduled=1 1", case.expected)
        self.assertIn("p0_changed=1\np0_final=0 x", case.expected)
        self.assertIn("k0_scheduled=0 0", case.expected)
        wide = ("33", "head_bit", "wide", "unsigned", "bl", "signed", "blocking", "z")
        source, fitted, left, right, *_ = interaction_concat.reference(wide, 0)
        self.assertEqual((source[0], fitted[0], left, right[-1]), ("z", "0", "0", "z"))
        self.assertEqual(len(fitted), 33)

    def test_packed_reductions_observe_controlling_bits_and_unknown_parity(self):
        r = interaction_logic.evaluate
        self.assertEqual(r("1xz"), {"and": "x", "nand": "x", "or": "1", "nor": "0",
                                    "xor": "x", "xnor": "x", "not": "0"})
        self.assertEqual((r("0xz")["and"], r("0xz")["or"], r("0xz")["not"]), ("0", "x", "x"))
        self.assertEqual((r("1" * 32)["xor"], r("1" * 33)["xor"]), ("0", "1"))
        one = ("1", "logic", "direct", "z", "low", "logic")
        result = interaction_logic.reference(one)[3]
        for op in ("and", "or", "xor"):
            self.assertEqual(result[op], ("x", "000000x"))

    def test_packed_logic_distinguishes_conversion_before_and_after_operation(self):
        row = ("65", "logic", "direct", "x", "high", "bit")
        self.assertEqual(interaction_logic.reference(row)[3]["not"], ("x", "0000000"))
        binary_input = (row[0], "bit", *row[2:])
        self.assertEqual(interaction_logic.reference(binary_input)[3]["not"], ("1", "0000001"))
        prefix = ("65", "logic", "prefix_one", "z", "high", "logic")
        result = interaction_logic.reference(prefix)[3]
        self.assertEqual(result["not"], ("0", "0000000"))
        self.assertEqual(result["xor"], ("x", "000000x"))
        self.assertTrue(interaction_logic.make_case(prefix).fourstate)

    def test_short_circuit_skips_only_decisive_right_operands(self):
        calls = interaction_shortcircuit.right_calls
        self.assertEqual([calls(op, "0") for op in ("and", "or", "imply", "equiv")], [0, 1, 0, 1])
        self.assertEqual([calls(op, "1") for op in ("and", "or", "imply", "equiv")], [1, 0, 1, 1])
        self.assertTrue(all(calls(op, "x") == 1 for op in interaction_shortcircuit.OPERATORS))
        r = interaction_shortcircuit.reference
        row = ("65", "same", "ll", "unknown", "one", "bit")
        result = r(row, "and")
        self.assertEqual((result["scalar"], result["wide"], result["calls_b"]),
                         ("x", "0000000", 1))
        self.assertEqual((r(row, "imply")["scalar"], r(row, "imply")["calls_b"]), ("1", 1))
        binary_left = (*row[:2], "bl", *row[3:])
        for op in ("and", "imply"):
            self.assertEqual(r(binary_left, op)["calls_b"], 0)

    def test_short_circuit_keeps_skipped_side_effects_and_all_xz_stimuli(self):
        row = ("1", "same", "ll", "zero", "one", "logic")
        result = interaction_shortcircuit.reference(row, "imply")
        self.assertEqual((result["scalar"], result["seen_a"], result["seen_b"]), ("1", "0", "0"))
        self.assertEqual((result["marker_a"], result["marker_b"]), ("a5", "69"))
        for a in ("0", "1", "x"):
            for b in ("0", "1", "x"):
                self.assertEqual(interaction_shortcircuit.logical("equiv", a, b),
                                 "x" if "x" in (a, b) else str(int(a == b)))
        unknown = ("33", "same", "ll", "unknown", "unknown", "logic")
        stimuli = interaction_shortcircuit.stimuli(unknown)
        self.assertEqual(len(stimuli), 6)
        pairs = {interaction_shortcircuit.inputs(unknown, phase)[:2]
                 for _, phase, baseline in stimuli if baseline is None}
        self.assertEqual(len(pairs), 4)

    def test_event_edges_use_expression_lsb_and_preserve_x_z_changes(self):
        events = interaction_edge.events
        self.assertEqual(events("0", "z"), (1, 0, 1))
        self.assertEqual(events("z", "1"), (1, 0, 1))
        self.assertEqual(events("1", "x"), (0, 1, 1))
        self.assertEqual(events("x", "0"), (0, 1, 1))
        self.assertEqual(events("x", "z"), (0, 0, 1))
        self.assertEqual(events("00", "10"), (0, 0, 1))
        row = ("129", "logic", "vector", "high", "x", "z", "nba")
        for bg in (0, 1):
            self.assertEqual(interaction_edge.reference(row, bg)[-1], (0, 0, 1))

    def test_event_expressions_observe_conversion_and_reduction_masking(self):
        row = ("65", "logic", "reduce_or", "high", "0", "1", "blocking")
        self.assertEqual(interaction_edge.reference(row, 0)[-1], (1, 0, 1))
        self.assertEqual(interaction_edge.reference(row, 1)[-1], (0, 0, 0))
        binary = ("33", "bit", "lsb", "low", "z", "1", "nba")
        self.assertEqual(interaction_edge.reference(binary, 0)[-1], (1, 0, 1))
        same_unknown = ("1", "logic", "reduce_or", "low", "x", "z", "blocking")
        self.assertEqual(interaction_edge.reference(same_unknown, 0)[-1], (0, 0, 0))
        self.assertTrue(interaction_edge.make_case(binary).fourstate)
        case = interaction_edge.make_case(("1", "logic", "vector", "low", "0", "1", "nba"))
        self.assertIn("b0_p_scheduled=0\nb0_p_final=1 expr=1 pos=1 neg=0 change=1", case.expected)

    def test_stream_partial_blocks_need_inverse_permutations_for_unpack(self):
        reorder = interaction_stream.reorder
        self.assertEqual(reorder("abcdef", "left", 4), "cdefab")
        self.assertEqual(reorder("abcdef", "left", 4, True), "efabcd")
        self.assertNotEqual(reorder(reorder("abcdef", "left", 4), "left", 4), "abcdef")
        for width in (1, 32, 33, 64, 65, 129, 132):
            bits = ("01xz" * ((width + 3) // 4))[:width]
            for size in (1, 4, 8, 16):
                self.assertEqual(reorder(reorder(bits, "left", size), "left", size, True), bits)
                self.assertEqual(reorder(bits, "right", size), bits)


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

    def test_build_reuses_targets_without_changing_per_run_evidence(self):
        runs = [deepcopy(self.run) for _ in range(3)]
        entries = list(runs[1]["tests"].values())
        entries[0]["status"], entries[1]["status"] = "known", "unsupported"
        next(iter(runs[2]["tests"].values()))["inputs_sha256"] = "old"
        expected = [self.evaluate(run) for run in runs]
        with tempfile.TemporaryDirectory() as directory:
            paths = [Path(directory) / f"run{i}.json" for i in range(3)]
            for path, run in zip(paths, runs):
                path.write_text(json.dumps(run))
            with mock.patch.object(coverage, "validate_files"), \
                    mock.patch.object(coverage, "source_digest", return_value="fixture"), \
                    mock.patch.object(suite_results, "input_digest", side_effect=lambda p:
                                      self.digests[p.relative_to(coverage.ROOT).as_posix()]), \
                    mock.patch.object(self.plan.model, "universe", wraps=self.plan.model.universe) as targets:
                result = coverage.build((self.plan,), paths)
            self.assertEqual(targets.call_count, 1)
            self.assertEqual([r["models"]["tiny"] for r in result["runs"]], expected)

    def test_next_build_with_same_model_id_recomputes_its_target_domain(self):
        model = Model("tiny", (("a", ("0", "1", "2")), ("b", ("0", "1"))), lambda r: True)
        changed = SuiteModel(model, self.plan.path, model.rows(), "changed fixture")
        with mock.patch.object(coverage, "validate_files"), \
                mock.patch.object(coverage, "source_digest", return_value="fixture"), \
                mock.patch.object(suite_results, "input_digest", return_value="fixture"):
            first = coverage.build((self.plan,), [])
            second = coverage.build((changed,), [])
        self.assertEqual(first["models"][0]["targets_by_strength"], {"2": 4})
        self.assertEqual(second["models"][0]["targets_by_strength"], {"2": 6})


if __name__ == "__main__":
    unittest.main()

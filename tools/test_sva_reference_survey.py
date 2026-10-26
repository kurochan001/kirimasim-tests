"""M3 normative Boolean and source-projection boundaries; no simulator needed."""

import json
from pathlib import Path
import tempfile
import unittest
from unittest import mock

from sva_reference import m3, survey
from sva_reference.engine import Current, Engine
from sva_reference.module import parse_module
from sva_reference.parser import Parser, Unsupported
from sva_reference.trace import read_vcd
from sva_reference.values import evaluate


def boolean(text):
    return evaluate(m3.expression(text), {})


class M3NormativeTests(unittest.TestCase):
    def test_followed_by_absent_antecedent_fails_each_trial_16_12_9_and_16_14_5(self):
        samples = [{"go": str(int(i == 0)), "a": str(int(i == 1)), "x": str(int(i == 1))} for i in range(5)]
        engine = Engine(samples)
        overlapping = engine.attempts("(go ##1 a) #-# x")
        nonoverlapping = engine.attempts("(go ##1 a) #=# x")
        self.assertEqual(sum(item.status == "failure" for item in overlapping), 4)
        self.assertEqual(sum(item.status == "failure" for item in nonoverlapping), 5)
        guarded = engine.attempts("go |-> (##1 a #-# x)")
        self.assertEqual(sum(item.status == "failure" for item in guarded), 0)

    def test_empty_sequence_alignment_16_9_2_1_and_16_12_7(self):
        engine = Engine([{"a": "0", "b": "0", "start": "1"}, {"a": "0", "b": "1", "start": "1"}], times=[10, 20])
        for text in ["start |-> (a[*0] ##1 b)", "a[*0] |=> b"]:
            attempts = engine.attempts(text)
            self.assertEqual([(item.status, item.time) for item in attempts], [("failure", 10), ("success", 20)])
    def test_boolean_implication_equivalence_and_table_11_2_precedence(self):
        for expr, expected in [("0 -> 0", "1"), ("1 -> 0", "0"), ("1 <-> 1", "1"),
                               ("1'bx -> 1", "1"), ("0 -> 1'bx", "1"), ("1'bx <-> 1", "x"),
                               ("1 ? 0 : 1 -> 0", "1"), ("0 -> 1 <-> 0", "1")]:
            self.assertEqual(boolean(expr).bits, expected, expr)

    def test_inside_11_4_13_ranges_and_asymmetric_unknown_wildcards(self):
        for expr, expected in [("3'd2 inside {0,[2:3],6}", "1"), ("3'd1 inside {0,[2:3],6}", "0"),
                               ("3'b101 inside {3'b1?1}", "1"), ("3'b1x1 inside {3'b1?1}", "1"),
                               ("3'bz11 inside {3'b1?1, 3'b011}", "x"),
                               ("3'd4 inside {[$:3]}", "0"), ("3'd4 inside {[4:$]}", "1")]:
            self.assertEqual(boolean(expr).bits, expected, expr)

    def test_dist_16_14_2_ignores_assert_cover_weights_but_honors_assume_zero(self):
        engine = Engine([{"a": "1"}])
        text = "a dist {1 := 0}"
        self.assertEqual(engine.property(text).status, "success")
        self.assertEqual(engine.property(text, kind="cover property").status, "success")
        self.assertEqual(engine.property(text, kind="assume property").status, "failure")
        self.assertEqual(engine.property("a dist {[0:1] :/ 2}", kind="assume property").status, "success")

    def test_let_11_12_expands_in_boolean_operands_and_preserves_self_determined_actuals(self):
        module = parse_module('''module m;
          let both(untyped a, untyped b) = a && b;
          let two(x) = x == 2'd2;
          x: assert property(@(posedge clk) both(a,b) && !two(a+b));
        endmodule''')
        self.assertEqual(Engine([{"a": "1", "b": "1"}]).property(module.directives[0].spec).status, "success")
        self.assertNotIn("let both", module.stimulus)

    def test_default_disable_unparenthesized_form_16_15(self):
        module = parse_module("module m; default disable iff rst; c: assert property(@(posedge clk) a); endmodule")
        engine = Engine([{"a": "1"}], times=[5], current=[Current(5, {"rst": "1"})])
        self.assertEqual(engine.property(module.directives[0].spec).status, "disabled")


class M3ProjectionTests(unittest.TestCase):
    def test_display_arguments_keep_spaces_inside_quoted_dictionary_keys(self):
        from sva_reference.pilots import displays
        display = displays('$display("%0d %s", n("A dual"), ends("empty ##1 b"));')[0]
        self.assertEqual(display.arguments, ('n("A dual")', 'ends("empty ##1 b")'))
        module = parse_module("module m; endmodule")
        state = {"A dual": 3, "empty ##1 b": [25]}
        self.assertEqual(m3.evaluate_report(display.arguments[0], state, {}, module, 30), 3)
        self.assertEqual(m3.evaluate_report(display.arguments[1], state, {}, module, 30), " 25")

    def test_literal_membership_and_table_projection_keep_read_values(self):
        source = '''module m;
          logic clk=0,a=0;
          bit [1:0] table_bits[2]='{2'b10,2'b01};
          function automatic logic at(int n, int ticks[$]);
            foreach(ticks[i]) if(ticks[i]==n) return 1; return 0;
          endfunction
          c: cover property(@(posedge clk) a);
          initial begin
            foreach(table_bits[k]) begin a=table_bits[k][0] || at(k,'{0,2}); #10; end
            $finish;
          end
        endmodule'''
        projected = m3.project(parse_module(source), {"at": True})
        self.assertIn("for (int k=0; k <= 1; k ++)", projected)
        self.assertIn("(k == 0) ? 2'b10", projected)
        self.assertIn("(k == 1) ? 2'b01", projected)
        self.assertIn("(k == 0) || (k == 2)", projected)
        self.assertNotIn("function automatic logic at", projected)

    def test_vcd_callback_keeps_off_clock_updates_without_resampling_them(self):
        vcd = '''$timescale 1ns $end
$scope module m $end
$var reg 1 ! clk $end
$var reg 1 " rst $end
$upscope $end
$enddefinitions $end
#0
0!
0"
#5
1!
#8
1"
#10
0!
#12
0"
#15
1!
'''
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "in.vcd"
            path.write_text(vcd)
            updates = []
            trace = read_vcd(path, "m.clk", ["m.rst"], current_callback=lambda t, v: updates.append((t, v)))
        self.assertEqual([tick.sampled["m.rst"] for tick in trace.ticks], ["0", "0"])
        self.assertIn((8, {"m.rst": "1"}), updates)
        self.assertIn((12, {"m.rst": "0"}), updates)

    def test_generation_of_all_m3_cases_never_reads_expected_files(self):
        original = Path.read_text
        def guard(path, *args, **kwargs):
            if path.suffix == ".expected":
                raise AssertionError("M3 generation opened expected output")
            return original(path, *args, **kwargs)
        with mock.patch.object(Path, "read_text", guard):
            results = [m3.generate(test) for test in json.loads(m3.MANIFEST.read_text())]
        self.assertEqual(len(results), 28)
        self.assertTrue(all(item.output for item in results))


class M3InventoryTests(unittest.TestCase):
    def test_approved_corrections_match_and_preserve_source_bound_judgments(self):
        result = survey.run()
        rows = {row["test"]: row for row in result["tests"]}
        judgments = json.loads((m3.HERE / "fixtures/m3_judgments.json").read_text())
        self.assertEqual(result["counts"]["match"], 28)
        self.assertNotIn("mismatch", result["counts"])
        self.assertEqual(len(judgments), 2)
        for test, judgment in judgments.items():
            row = rows[test]
            self.assertEqual(row["judgment"]["disposition"], "corrected_after_user_approval")
            self.assertFalse(row["judgment"]["approval_required"])
            self.assertEqual(row["source_sha256"], judgment["correction"]["source_sha256"])
            self.assertEqual(row["expected_sha256"], judgment["correction"]["actual_sha256"])
            self.assertNotEqual(judgment["expected_sha256"], row["expected_sha256"])
            self.assertTrue(judgment["clauses"])

    def test_survey_emit_only_does_not_read_expectations(self):
        original = Path.read_text
        def guard(path, *args, **kwargs):
            if path.suffix == ".expected":
                raise AssertionError("M3 emit-only opened an expectation")
            return original(path, *args, **kwargs)
        with mock.patch.object(Path, "read_text", guard):
            result = survey.run(emit_only=True)
        self.assertEqual(result["counts"]["generated"], len(json.loads(m3.MANIFEST.read_text())))
        self.assertNotIn("mismatch", result["counts"])
    def test_inventory_accounts_for_all_candidates_and_preserves_gaps(self):
        rows = survey.inventory()
        from collections import Counter
        counts = Counter(row["status"] for row in rows)
        self.assertEqual(counts["v1"], len(json.loads(m3.MANIFEST.read_text())))
        self.assertEqual(counts["pilot"], 10)
        self.assertTrue(counts["out_of_scope"] > 0 and counts["excluded_illegal"] > 0)
        self.assertEqual(len({row["test"] for row in rows}), len(rows))
        row = {"test": "tests/ch16/test_new.sv", "body": "module m; c: assert property(@(posedge clk) a); endmodule", "header": "", "illegal": False}
        status, _, _ = survey.classify(row, {})
        self.assertEqual(status, "in_scope_unhandled")

    def test_parse_failure_does_not_turn_into_an_exclusion_without_scope_evidence(self):
        row = {"test": "tests/ch16/test_new.sv", "body": "module m; c: assert property(@(posedge clk) mystery syntax); endmodule", "header": "", "illegal": False}
        status, _, _ = survey.classify(row, {})
        self.assertEqual(status, "in_scope_unhandled")


if __name__ == "__main__":
    unittest.main()

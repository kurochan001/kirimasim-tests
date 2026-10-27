"""Clause-based M4 history, defaults and context tests (16.5.1/16.9.3)."""

import itertools
import json
from pathlib import Path
import tempfile
import unittest
from unittest import mock

from sva_reference.bridge import signal_defaults
from sva_reference.engine import Current, Engine
from sva_reference.module import parse_module
from sva_reference.parser import Parser, Unsupported
from sva_reference.sampled import History
from sva_reference.values import Bits


def expr(text):
    parser = Parser(text)
    node = parser.boolean()
    parser.finish()
    return node


class SampledValueTests(unittest.TestCase):
    def test_all_four_state_lsb_transitions_16_9_3(self):
        for old, new in itertools.product("01xz", repeat=2):
            history = History([{"v": old}, {"v": new}], defaults={"v": "z"})
            for name, expected in [("rose", new == "1" and old != "1"),
                                   ("fell", new == "0" and old != "0"),
                                   ("stable", new == old), ("changed", new != old)]:
                self.assertEqual(history.evaluate(expr(f"${name}(v)"), 1).bits, str(int(expected)))

    def test_upper_bits_only_affect_stable_changed(self):
        history = History([{"v": "00"}, {"v": "10"}], defaults={"v": "00"})
        self.assertEqual([history.evaluate(expr(f"${name}(v)"), 1).bits
                          for name in ["rose", "fell", "stable", "changed"]], ["0", "0", "0", "1"])

    def test_first_tick_uses_declaration_default_not_first_sample(self):
        history = History([{"v": "1"}], defaults={"v": "x"})
        self.assertEqual(history.evaluate(expr("$past(v)"), 0).bits, "x")
        self.assertEqual(history.evaluate(expr("$rose(v)"), 0).bits, "1")
        self.assertEqual(history.evaluate(expr("$sampled(v)"), 0).bits, "1")

    def test_past_gate_counts_only_strict_prior_true_ticks(self):
        history = History([{"v": i + 1, "g": g} for i, g in enumerate(["1", "0", "x", "1", "z", "1"])],
                          defaults={"v": 17, "g": "0"})
        self.assertEqual([history.evaluate(expr("$past(v, 1, g)"), i).integer() for i in range(6)], [17, 1, 1, 1, 4, 4])
        self.assertEqual(history.evaluate(expr("$past(v, 2, g)"), 3).integer(), 17)
        self.assertEqual(history.evaluate(expr("$past(v, 2, g)"), 5).integer(), 1)

    def test_history_does_not_depend_on_calls_or_assertion_attempts(self):
        history = History([{"v": v} for v in [2, 4, 6, 8]], defaults={"v": 0})
        self.assertEqual(history.evaluate(expr("$past(v)"), 3).integer(), 6)
        self.assertEqual(history.evaluate(expr("$past(v,3)"), 3).integer(), 2)

    def test_compound_expression_default_is_evaluated_recursively(self):
        history = History([{"a": 8, "b": 9}], defaults={"a": 2, "b": 3})
        self.assertEqual(history.evaluate(expr("$past(a + b)"), 0).integer(), 5)

    def test_call_argument_is_self_determined_and_preserves_signed_width(self):
        history = History([{"a": Bits("11", True)}], defaults={"a": Bits("10", True)})
        self.assertEqual(history.evaluate(expr("$past(a)"), 0), Bits("10", True))
        self.assertEqual(history.evaluate(expr("$sampled(a+a) == 32'sd2"), 0).bits, "0")

    def test_same_clock_explicit_arguments_and_omissions(self):
        history = History([{"a": 9, "g": "1"}, {"a": 7, "g": "0"}], defaults={"a": 3}, clock=("clk", "posedge"))
        for text in ["$past(a)", "$past(a,,)", "$past(a,,,)", "$past(a, , , @(posedge clk))", "$past(a,,g)"]:
            self.assertEqual(history.evaluate(expr(text), 1).integer(), 9)
        self.assertEqual(history.evaluate(expr("$rose(a, @(posedge clk))"), 1).bits, "0")

    def test_different_or_unknown_clock_fails_explicitly(self):
        history = History([{"a": "1"}], defaults={"a": "0"}, clock=("clk", "posedge"))
        for text in ["$past(a,,, @(posedge other))", "$rose(a,@(negedge clk))"]:
            with self.assertRaisesRegex(Unsupported, "different or unresolved clock"):
                history.evaluate(expr(text), 0)

    def test_invalid_counts_and_arguments_fail_closed(self):
        history = History([{"a": "1", "n": 1}], defaults={"a": "0"})
        for text in ["$past(a,0)", "$past(a,-1)", "$past(a,n)", "$past(a,1'bx)"]:
            with self.assertRaises(Unsupported):
                history.evaluate(expr(text), 0)
        for text in ["$sampled(a,)", "$sampled()", "$past(a,@(posedge clk))", "$rose(a,a)", "$past(a,1,1,1)"]:
            with self.assertRaises(Unsupported):
                expr(text)

    def test_missing_defaults_are_not_replaced_by_first_sample(self):
        with self.assertRaisesRegex(Unsupported, "unknown signal"):
            History([{"a": "1"}]).evaluate(expr("$past(a)"), 0)

    def test_live_action_names_and_sampled_names_are_separate(self):
        history = History([{"a": "0", "b": "1"}], defaults={"a": "0", "b": "1"})
        live = {"a": "0", "b": "0"}
        self.assertEqual(history.evaluate(expr("a==b && $sampled(a)!=$sampled(b)"), 0, live=live).bits, "1")

    def test_defaults_from_static_initializers_types_and_nets_16_5_1(self):
        module = parse_module("""module m;
          logic clk=0, a=1'b1, u;
          bit b;
          int n=-3;
          logic [2:5] v=4'b1010;
          wire [3:0] w=4'b0101;
          initial begin a=0; n=5; end
        endmodule""")
        defaults = signal_defaults(module)
        self.assertEqual(defaults["a"].bits, "1")
        self.assertEqual(defaults["u"].bits, "x")
        self.assertEqual(defaults["b"].bits, "0")
        self.assertEqual(defaults["n"].integer(), -3)
        self.assertEqual(defaults["v"].bit(2), "1")
        self.assertEqual(defaults["w"].bits, "xxxx")

    def test_history_is_shared_by_temporal_consequent_and_sequence(self):
        engine = Engine([{"a": "0"}, {"a": "1"}, {"a": "0"}], defaults={"a": "0"})
        self.assertEqual([(m.start, m.end) for m in engine.matches("a ##1 $fell(a)", 1)], [(1, 2)])
        self.assertEqual(engine.property("$rose(a) |=> $past(a)", 1).status, "success")
        self.assertEqual(engine.property("if ($rose(a)) a else !a", 1).status, "success")

    def test_sampled_disable_uses_sample_not_live_reset(self):
        engine = Engine([{"rst": "0"}], times=[5], current=[Current(5, {"rst": "1"})])
        self.assertEqual(engine.property("disable iff(rst) 0").status, "disabled")
        self.assertEqual(engine.property("disable iff($sampled(rst)) 0").status, "failure")

    def test_off_tick_sampled_disable_and_implicit_history_disable_rejected(self):
        engine = Engine([{"rst": "0"}, {"rst": "0"}], times=[5,15], defaults={"rst":"0"},
                        current=[Current(5,{"rst":"0"}), Current(8,{"rst":"1"},"change"),Current(15,{"rst":"0"})])
        with self.assertRaisesRegex(Unsupported,"off-clock sampled disable"):
            engine.property("disable iff($sampled(rst)) 1 |=> 1")
        with self.assertRaisesRegex(Unsupported,"needs an explicit clock"):
            engine.property("disable iff($past(rst)) 0")


class M4IntegrationTests(unittest.TestCase):
    def test_all_outputs_generated_before_first_expectation_read(self):
        from sva_reference import m4
        original_read, original_generate = Path.read_text, m4.generate
        generated = []
        def generate(test, **kwargs):
            item = original_generate(test, **kwargs)
            generated.append(test)
            return item
        def read(path, *args, **kwargs):
            if path.suffix == ".expected":
                self.assertEqual(len(generated), 7)
            return original_read(path, *args, **kwargs)
        with mock.patch.object(m4, "generate", generate), mock.patch.object(Path, "read_text", read):
            result = m4.run()
        self.assertEqual(result["counts"], {"deferred": 16, "match": 7})

    def test_emit_only_never_opens_expected_and_writes_evidence(self):
        from sva_reference import m4
        original = Path.read_text
        def read(path, *args, **kwargs):
            if path.suffix == ".expected":
                raise AssertionError("M4 generation read expected output")
            return original(path, *args, **kwargs)
        with tempfile.TemporaryDirectory() as directory, mock.patch.object(Path,"read_text",read):
            result = m4.run(emit_only=True, output_dir=directory)
            self.assertEqual(result["counts"], {"deferred": 16, "generated": 7})
            self.assertEqual(len(list(Path(directory).glob("*.actual"))),7)
            self.assertEqual(len(list(Path(directory).glob("*.events.json"))),7)

    def test_region_separation_survives_nba_stimulus(self):
        from sva_reference import m4
        test = "tests/ch16/test_sampled_in_action_block.sv"
        item = m4.generate(test)
        self.assertEqual(item.attempts["a1"]["failure"], 1)
        report = item.attempts["sampled_reports"][0]
        self.assertEqual(report["context"], "action")
        # First argument is time; then live a,b; then sampled a,b.
        self.assertEqual([arg["bits"] for arg in report["arguments"]][1:], ["0","0","0","1"])

    def test_explicit_clock_arguments_keep_keyword_boundaries(self):
        from sva_reference import m4
        item = m4.displays('$display("%b", $stable(a, @(posedge clk)));')[0]
        self.assertIn("posedge clk",item.arguments[0])
        self.assertEqual(expr(item.arguments[0]).args[1].value,("clk","posedge"))

    def test_source_and_default_provenance_invalidate_cached_inputs(self):
        from sva_reference import m4
        test="tests/ch16/test_past_gating_expression.sv"
        case=json.loads(m4.MANIFEST.read_text())[test]
        source=(m4.ROOT/test).read_bytes()
        module=parse_module(source.decode())
        changed=parse_module(source.decode().replace("int a = 0;","int a = 7;"))
        with self.assertRaisesRegex(ValueError,"stale M4"):
            m4.load_input(test,source,changed,case)
        bad={**case,"source_sha256":"0"*64}
        with mock.patch.object(m4.MANIFEST.__class__,"read_text",return_value=json.dumps({test:bad})):
            with self.assertRaisesRegex(Unsupported,"source changed"):
                m4.generate(test)

    def test_projection_contains_no_sampled_function_or_action(self):
        from sva_reference import m3,m4
        from sva_reference.source import tokens
        from sva_reference.parser import SAMPLED
        for test in json.loads(m4.MANIFEST.read_text()):
            module=parse_module((m4.ROOT/test).read_text())
            words={token.text for token in tokens(m3.project(module,{}))}
            self.assertFalse(words&SAMPLED)
            self.assertFalse(words&{"assert","assume","cover","$display"})

    def test_a_missing_audited_source_is_reported_not_silently_omitted(self):
        from sva_reference import m4
        with mock.patch.object(m4.survey,"candidates",return_value=[]):
            rows=m4.inventory()
        self.assertEqual(len(rows),7)
        self.assertTrue(all(row["status"]=="unhandled" for row in rows))


if __name__ == "__main__":
    unittest.main()

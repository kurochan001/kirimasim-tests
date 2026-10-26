"""Independent normative examples and boundary cases; never reads .expected."""

import json
from pathlib import Path
import unittest

from sva_reference import automata as rx
from sva_reference.engine import Current, Engine
from sva_reference.module import parse_module
from sva_reference.parser import Node, Parser, Unsupported, parse_spec
from sva_reference.values import Bits, evaluate


def rows(**signals):
    length = len(next(iter(signals.values())))
    if any(len(values) != length for values in signals.values()):
        raise ValueError("test inputs differ in length")
    return [{name: value[i] for name, value in signals.items()} for i in range(length)]


def boolean(text, values=None):
    parser = Parser(text)
    node = parser.boolean()
    parser.finish()
    return evaluate(node, values or {})


class NormativeExampleTests(unittest.TestCase):
    def test_chapter_16_figures_with_explicit_match_ticks(self):
        path = Path(__file__).with_name("sva_reference") / "fixtures/lrm_examples.json"
        data = json.loads(path.read_text())
        for example in data["examples"]:
            with self.subTest(clause=example["clause"], figure=example["figure"]):
                samples = [{name: str(int(tick in ones)) for name, ones in example["ones"].items()}
                           for tick in range(1, example["ticks"] + 1)]
                matches = Engine(samples).matches(example["expression"], example["start"] - 1)
                self.assertEqual([match.end + 1 for match in matches], example["ends"])

    def test_first_match_tie_example_16_9_8(self):
        engine = Engine(rows(a="1000", b="0010", c="1000", d="0010"))
        self.assertEqual([m.end for m in engine.matches("first_match((a ##[2:3] b) or (c ##[1:2] d))")], [2, 2])

    def test_empty_concatenation_equivalence_16_9_2_1(self):
        engine = Engine(rows(b="10000", a="01000", c="00110"))
        left = engine.matches("b ##1 a[*0:1] ##2 c")
        right = engine.matches("(b ##2 c) or (b ##1 a ##2 c)")
        self.assertEqual(left, right)
        self.assertEqual([m.end for m in left], [2, 3])

    def test_case_delay_example_16_12_16(self):
        expression = "case(d) 2'd0: a && b; 2'd1: a ##2 b; 2'd2: a ##4 b; 2'd3: a ##8 b; default: 0; endcase"
        for choice, offset in [("00", 0), ("01", 2), ("10", 4), ("11", 8)]:
            samples = rows(d=[choice] * 9, a="100000000", b="".join("1" if i == offset else "0" for i in range(9)))
            self.assertEqual(Engine(samples).property(expression).tick, offset)
        self.assertEqual(Engine(rows(d=["xx"], a="1", b="1")).property(expression).status, "failure")


class SequenceSemanticsTests(unittest.TestCase):
    def ends(self, expression, **signals):
        return [match.end for match in Engine(rows(**signals)).matches(expression)]

    def test_repeat_fixed_range_unbounded_and_nested(self):
        self.assertEqual(self.ends("a[*2:3]", a="1110"), [1, 2])
        self.assertEqual(self.ends("a[+]", a="1110"), [0, 1, 2])
        self.assertEqual(self.ends("a[*]", a="110"), [-1, 0, 1])
        self.assertEqual(self.ends("(a ##1 b)[*2]", a="10100", b="01010"), [3])
        self.assertEqual(self.ends("(a[*1:2])[*2]", a="11110"), [1, 2, 2, 3])

    def test_empty_intervals_and_zero_delay(self):
        self.assertEqual(self.ends("a[*0] ##0 b", a="1", b="1"), [])
        self.assertEqual(self.ends("a ##0 b[*0]", a="1", b="1"), [])
        self.assertEqual(self.ends("a[*0] ##2 b", a="00", b="01"), [1])
        self.assertEqual(self.ends("a ##2 b[*0]", a="10", b="00"), [1])
        self.assertEqual(self.ends("a[*0] ##2 b[*0]", a="0", b="0"), [0])
        self.assertEqual(self.ends("a ##0 b", a="1", b="1"), [0])

    def test_goto_nonconsecutive_and_range(self):
        signals = dict(s="1000000", b="0101000", c="0000010")
        self.assertEqual(self.ends("s ##1 b[->2] ##1 c", **signals), [])
        self.assertEqual(self.ends("s ##1 b[=2] ##1 c", **signals), [5])
        self.assertEqual(self.ends("b[->1:2]", b="010100"), [1, 3])
        self.assertEqual(self.ends("b[=1]", b="010100"), [1, 2])
        self.assertEqual(self.ends("b[->0]", b="1"), [-1])
        self.assertEqual(self.ends("b[=0]", b="001"), [-1, 0, 1])

    def test_sequence_or_multiplicity_and_boolean_or(self):
        self.assertEqual(self.ends("(a ##1 b) or (a ##1 c)", a="10", b="01", c="01"), [1, 1])
        self.assertEqual(self.ends("a or b", a="1", b="1"), [0])
        self.assertEqual(self.ends("a[*1] or b", a="1", b="1"), [0, 0])

    def test_intersect_requires_equal_endpoints(self):
        self.assertEqual(self.ends("(a ##[1:3] b) intersect (a ##2 c)", a="1000", b="0111", c="0010"), [2])

    def test_first_match_filters_early_continuations_but_preserves_ties(self):
        signals = dict(a="1000", b="0110", c="0001")
        self.assertEqual(self.ends("first_match(a ##[1:3] b) ##1 c", **signals), [])
        self.assertEqual(self.ends("(a ##[1:3] b) ##1 c", **signals), [3])
        self.assertEqual(self.ends("first_match(a[*0:2])", a="11"), [-1])

    def test_within_includes_both_boundaries_and_counts_inner_matches(self):
        self.assertEqual(self.ends("(x ##1 x) within (s ##3 s)", x="0011", s="1001"), [3])
        self.assertEqual(self.ends("(x ##1 x) within (s ##3 s)", x="1100", s="1001"), [3])
        self.assertEqual(self.ends("(x ##1 x) within (s ##3 s)", x="1111", s="1001"), [3, 3, 3])

    def test_throughout_includes_first_and_last_tick(self):
        self.assertEqual(self.ends("en throughout ##2 ack", en="011", ack="001"), [])
        self.assertEqual(self.ends("en throughout ##2 ack", en="110", ack="001"), [])
        self.assertEqual(self.ends("en throughout ##2 ack", en="111", ack="001"), [2])

    def test_unbounded_viability_uses_a_cycle_instead_of_a_horizon(self):
        # Common lengths are multiples of six, beyond either operand's first
        # completion. The second intersection has no common future length.
        possible = rx.compile_sequence(parse_spec("(1 ##1 1)[+] intersect (1 ##1 1 ##1 1)[+]").body)
        impossible = rx.compile_sequence(parse_spec("((1 ##1 1)[*] ##1 1) intersect (1 ##1 1)[+]").body)
        self.assertTrue(rx.viable(possible))
        self.assertFalse(rx.viable(impossible))


class PropertySemanticsTests(unittest.TestCase):
    def test_sequence_success_and_earliest_failure_ticks(self):
        engine = Engine(rows(a="1000", b="0000"), times=[5, 15, 25, 35])
        result = engine.property("a ##[1:2] b")
        self.assertEqual((result.status, result.tick, result.time), ("failure", 2, 25))
        self.assertEqual(engine.property("a ##[1:$] b").status, "holds")
        self.assertEqual(engine.property("strong(a ##[1:$] b)").status, "pending")

    def test_four_finite_levels_and_negation_strength(self):
        engine = Engine(rows(a="1", b="0"))
        for text, level, truth in [("a", "holds_strongly", True), ("b", "fails", False),
                                   ("a ##1 b", "holds", True), ("strong(a ##1 b)", "pending", False),
                                   ("not (a ##1 b)", "pending", False),
                                   ("not strong(a ##1 b)", "holds", True)]:
            with self.subTest(text=text):
                result = engine.property(text)
                self.assertEqual((result.satisfaction, result.finite_truth), (level, truth))
        self.assertEqual(engine.property("a ##1 b", kind="cover property").status, "pending")
        self.assertEqual(engine.property("a ##1 b", kind="assume property").status, "holds")

    def test_implication_is_universal_and_followed_by_is_existential(self):
        engine = Engine(rows(a="1000", b="0110", c="0010"))
        universal = engine.property("(a ##[1:2] b) |-> c")
        exists = engine.property("(a ##[1:2] b) #-# c")
        self.assertEqual((universal.status, universal.tick), ("failure", 1))
        self.assertEqual((exists.status, exists.tick), ("success", 2))
        self.assertEqual(Engine(rows(a="0", b="0")).property("a |-> b").status, "vacuous")
        self.assertEqual(Engine(rows(a="0", b="0")).property("a #-# b").status, "failure")

    def test_nonoverlap_including_an_empty_antecedent(self):
        engine = Engine(rows(a="10", b="01"))
        self.assertEqual(engine.property("a |=> b").tick, 1)
        self.assertEqual(engine.property("a #=# b").tick, 1)
        self.assertEqual(engine.property("a[*0] |=> a").tick, 0)

    def test_property_or_and_have_single_decision(self):
        engine = Engine(rows(a="1000", b="0010", c="0001"))
        self.assertEqual(engine.property("(a ##2 b) or (a ##3 c)").tick, 2)
        self.assertEqual(engine.property("(a ##2 b) and (a ##3 c)").tick, 3)

    def test_nexttime_and_all_bounded_temporal_forms(self):
        engine = Engine(rows(p="0010"))
        self.assertEqual(engine.property("nexttime p").tick, 1)
        self.assertEqual(engine.property("nexttime [2] p").status, "success")
        self.assertEqual(engine.property("s_nexttime [2] p").status, "success")
        self.assertEqual(engine.property("eventually [1:3] p").tick, 2)
        self.assertEqual(engine.property("s_eventually [1:3] p").tick, 2)
        self.assertEqual(engine.property("always [1:3] p").tick, 1)
        self.assertEqual(engine.property("s_always [2:2] p").status, "success")
        self.assertEqual(engine.property("nexttime [4] p").status, "holds")
        self.assertEqual(engine.property("s_nexttime [4] p").status, "pending")
        self.assertEqual(engine.property("always [4:5] p").status, "holds")
        self.assertEqual(engine.property("s_always [4:5] p").status, "pending")
        self.assertEqual(engine.property("eventually [4:5] p").status, "holds")
        self.assertEqual(engine.property("s_eventually [4:5] p").status, "pending")

    def test_until_forms_and_temporal_property_operands(self):
        engine = Engine(rows(p="1100", q="0010"))
        for operator in ("until", "s_until"):
            self.assertEqual(engine.property(f"p {operator} q").tick, 2)
            self.assertEqual(engine.property(f"p {operator} q").status, "success")
        for operator in ("until_with", "s_until_with"):
            self.assertEqual(engine.property(f"p {operator} q").status, "failure")
        result = Engine(rows(p="111", q="000")).property("p until q")
        self.assertEqual(result.status, "holds")
        self.assertEqual(Engine(rows(p="111", q="000")).property("p s_until q").status, "pending")
        # q at tick 0 is itself a property whose result arrives at tick 2.
        result = engine.property("p until nexttime [2] q")
        self.assertEqual((result.status, result.tick), ("success", 2))

    def test_boolean_property_operators_and_conditionals(self):
        engine = Engine(rows(p="1", q="0"))
        for text, status in [("not p", "failure"), ("p or q", "success"),
                             ("p and q", "failure"), ("p implies q", "failure"),
                             ("p iff q", "failure"), ("if(q) p", "vacuous"),
                             ("if(p) q else p", "failure"),
                             ("case(q) 1: p; endcase", "vacuous")]:
            self.assertEqual(engine.property(text).status, status, text)

    def test_cover_sequence_retains_all_matches_property_succeeds_once(self):
        engine = Engine(rows(a="1000", b="0111"))
        expression = "a ##[1:3] b"
        self.assertEqual([m.end for m in engine.sequence_coverage(expression)], [1, 2, 3])
        attempts = engine.attempts(expression, kind="cover property")
        self.assertEqual([a.tick for a in attempts if a.status == "success"], [1])

    def test_disable_uses_current_values_and_can_interrupt_between_ticks(self):
        samples = rows(a="100", b="001", rst="000")
        engine = Engine(samples, times=[5, 15, 25], current=[
            Current(5, {"rst": "0"}), Current(12, {"rst": "1"}),
            Current(15, {"rst": "0"}), Current(25, {"rst": "0"})])
        result = engine.property("disable iff(rst) a ##2 b")
        self.assertEqual((result.status, result.time, result.tick), ("disabled", 12, None))
        current = [Current(t, {"rst": "1" if t == 5 else "0"}) for t in [5, 15, 25]]
        self.assertEqual(Engine(samples, times=[5, 15, 25], current=current).property("disable iff(rst) a").status, "disabled")
        with self.assertRaisesRegex(Unsupported, "current-value events"):
            Engine(samples).property("disable iff(rst) a")

    def test_disable_after_decision_cannot_retract_success_and_kills_coverage(self):
        samples = rows(a="100", b="011")
        events = [Current(5, {"rst": "0"}), Current(15, {"rst": "0"}), Current(20, {"rst": "1"}), Current(25, {"rst": "0"})]
        engine = Engine(samples, times=[5, 15, 25], current=events)
        self.assertEqual(engine.property("disable iff(rst) a ##1 b").status, "success")
        self.assertEqual([m.end for m in engine.sequence_coverage("disable iff(rst) a ##[1:2] b")], [1])

    def test_disable_region_boundaries_and_same_timestamp_updates(self):
        samples = rows(a="11", b="01")
        events = [Current(5, {"rst": "1"}, "change"),
                  Current(5, {"rst": "0"}),
                  Current(15, {"rst": "0"}),
                  Current(15, {"rst": "1"}, "change")]
        engine = Engine(samples, times=[5, 15], current=events)
        self.assertEqual(engine.property("disable iff(rst) a ##1 b").status, "success")
        # The same reset change is inside an attempt still pending after the
        # final Observed region; it therefore cancels that attempt.
        self.assertEqual(engine.property("disable iff(rst) a ##2 b").status, "disabled")
        earlier_reset = [*events[:2], Current(15, {"rst": "1"}, "change"), Current(15, {"rst": "0"})]
        self.assertEqual(Engine(samples, times=[5, 15], current=earlier_reset).property("disable iff(rst) a ##1 b").status, "disabled")


class ParserAndDeclarationTests(unittest.TestCase):
    def test_binding_powers_and_associativity_from_tables_16_1_and_16_3(self):
        node = parse_spec("a ##1 b throughout c within d intersect e and f or g").body
        self.assertEqual(node.op, "or")
        self.assertEqual(node.args[0].op, "and")
        self.assertEqual(node.args[0].args[0].op, "intersect")
        self.assertEqual(node.args[0].args[0].args[0].op, "within")
        self.assertEqual(node.args[0].args[0].args[0].args[0].op, "throughout")
        self.assertEqual(parse_spec("not a ##1 b and c").body.args[0].op, "not")
        self.assertEqual(parse_spec("p implies q implies r").body.args[1].op, "implies")
        self.assertEqual(parse_spec("p iff q until r").body.args[0].op, "iff")
        self.assertEqual(parse_spec("always p |-> q").body.args[0].op, "|->")

    def test_parenthesized_boolean_operands_and_constant_arithmetic_bounds(self):
        engine = Engine(rows(a="100", b="001"))
        self.assertEqual(engine.property("(a) && !b").status, "success")
        self.assertEqual(engine.property("a ##(1+1) b").tick, 2)
        self.assertEqual(engine.property("nexttime [1+1] b").tick, 2)

    def test_named_sequence_property_expression_args_and_typed_casts(self):
        source = '''module m;
        sequence delay(a, n); a ##n a; endsequence
        property p(a); @(posedge clk) delay(a, 2); endproperty
        sequence lowbit(bit x); x; endsequence
        x: assert property (p(req || ack));
        y: cover property (@(posedge clk) lowbit(data));
        endmodule'''
        module = parse_module(source)
        engine = Engine(rows(req="101", ack="000", data=["10", "10", "10"]))
        self.assertEqual(engine.property(module.directives[0].spec).tick, 2)
        self.assertEqual(engine.property(module.directives[1].spec).status, "failure")
        self.assertNotIn("sequence delay", module.stimulus)
        self.assertNotIn("assert property", module.stimulus)

    def test_default_clock_disable_and_unlabeled_directives(self):
        module = parse_module('''module m;
        default clocking cb @(negedge clk); endclocking
        default disable iff(rst);
        assert property(a);
        c: cover sequence (a ##1 b);
        endmodule''')
        self.assertEqual(module.directives[0].spec.edge, "negedge")
        self.assertEqual(module.directives[1].spec.disable.value, "rst")
        self.assertEqual(module.directives[0].source.label, "unnamed_1")

    def test_typed_formals_inherit_types_and_preserve_packed_indices(self):
        module = parse_module('''module m;
        sequence s(bit a, b, untyped c); !a && !b && c[7]; endsequence
        sequence ascending(logic [4:7] a); a[4:5] == 2'b10; endsequence
        sequence two_state(int a); a == 0; endsequence
        sequence four_state(integer a); a[0] === 1'bx; endsequence
        c1: cover property(@(posedge clk) s(x, x, vec));
        c2: cover property(@(posedge clk) ascending(vec));
        c3: cover property(@(posedge clk) two_state(x));
        c4: cover property(@(posedge clk) four_state(x));
        endmodule''')
        engine = Engine([{"x": "x", "vec": Bits("1000", lsb=4)}])
        self.assertTrue(all(engine.property(d.spec).status == "success" for d in module.directives))

    def test_named_default_and_omitted_arguments_are_bound_in_order(self):
        module = parse_module('''module m;
        sequence s(a, b=1, n=2); a ##n b; endsequence
        x: assert property(@(posedge clk) s(req));
        y: assert property(@(posedge clk) s(.n(1), .a(req)));
        z: assert property(@(posedge clk) s(req,,0));
        endmodule''')
        engine = Engine(rows(req="100"))
        self.assertEqual([engine.property(d.spec).tick for d in module.directives], [2, 1, 0])
        with self.assertRaisesRegex(Unsupported, "duplicate argument"):
            parse_module("module m; sequence s(a); a; endsequence x: assert property(@(posedge clk) s(1,.a(0))); endmodule")

    def test_static_parameter_bounds_and_typed_actual_assignment_context(self):
        module = parse_module('''module m;
        localparam int N=1, M=N+1;
        sequence s(logic [4:0] value); value == 5'b10000; endsequence
        sequence fill(logic [4:0] value); value == 5'b11111; endsequence
        x: cover property(@(posedge clk) s(4'b1111+4'b0001));
        y: cover property(@(posedge clk) fill('1));
        z: assert property(@(posedge clk) a ##M b);
        endmodule''')
        engine = Engine(rows(a="100", b="001"))
        self.assertEqual(module.parameters["M"].integer(), 2)
        self.assertEqual([engine.property(d.spec).tick for d in module.directives], [0, 0, 2])
        self.assertTrue(all(engine.property(d.spec).status == "success" for d in module.directives))

    def test_general_engine_reproduces_completed_m0_action_schedules_offline(self):
        # Compare independently implemented evaluators only after the normative
        # tests above; no existing suite expected-output files are read.
        from sva_reference import m0
        from sva_reference.trace import load_trace
        for name, signals in m0.PILOTS.items():
            with self.subTest(name=name):
                source = (m0.ROOT / "tests/ch16" / f"{name}.sv").read_bytes()
                trace = load_trace(m0.FIXTURES / f"{name}.json", source, f"{name}.clk",
                                   [f"{name}.{signal}" for signal in signals])
                samples = [{key.split(".", 1)[1]: value for key, value in tick.sampled.items()} for tick in trace.ticks]
                engine = Engine(samples)
                actions = []
                for directive in parse_module(source.decode()).directives:
                    for attempt in engine.attempts(directive.spec, kind=directive.source.kind):
                        branch = "pass" if attempt.status in {"success", "vacuous"} else "fail" if attempt.status == "failure" else None
                        body = directive.source.passed if branch == "pass" else directive.source.failed
                        if branch and body != ";" and (branch == "pass" or directive.source.kind != "cover property"):
                            actions.append((directive.source.label, attempt.start, attempt.tick, branch))
                pilot = [(a.label, a.start, a.end, a.branch) for a in m0.evaluate(name, trace)]
                self.assertEqual(sorted(actions), sorted(pilot))

    def test_fail_closed_outside_scope_illegal_ranges_and_recursion(self):
        for expression in ["$past(a)", "$rose(a)", "accept_on(rst) a", "a.matched",
                           "eventually [1:$] a", "s_always [1:$] a", "a ##[-1:2] b",
                           "a[*3:2]", "(a, x=1)", "@(posedge clk) @(posedge other) a"]:
            with self.subTest(expression=expression), self.assertRaises(Unsupported):
                parse_spec(expression)
        with self.assertRaisesRegex(Unsupported, "recursive"):
            parse_module("module m; property p; p; endproperty x: assert property(@(posedge clk) p); endmodule")
        with self.assertRaisesRegex(Unsupported, "multiple clocks"):
            parse_module("module m; x: assert property(@(posedge a) x); y: assert property(@(posedge b) y); endmodule")
        with self.assertRaisesRegex(Unsupported, "empty matches"):
            Engine(rows(a="1")).property("a[*0:1]")
        with self.assertRaisesRegex(Unsupported, "empty-admitting"):
            Engine(rows(a="1")).matches("(a[*0:1])[*]")


class FourStateExpressionTests(unittest.TestCase):
    def test_logical_four_state_and_assertion_truth(self):
        for expression, bits in [("1'bx && 0", "0"), ("1'bx || 1", "1"),
                                 ("!1'bz", "x"), ("1'bx && 1", "x"),
                                 ("4'b1xxx != 4'b0000", "1")]:
            self.assertEqual(boolean(expression).bits, bits, expression)
        self.assertTrue(boolean("4'b1xxx").assertion())
        self.assertFalse(boolean("4'b0xxx").assertion())

    def test_case_and_wildcard_equality(self):
        self.assertEqual(boolean("4'b10xz === 4'b10xz").bits, "1")
        self.assertEqual(boolean("4'b10xz == 4'b10xz").bits, "x")
        self.assertEqual(boolean("4'b1001 ==? 4'b1xx1").bits, "1")
        self.assertEqual(boolean("4'b1x01 ==? 4'b1001").bits, "x")

    def test_bitwise_select_concat_reductions_and_unknown_ternary_merge(self):
        self.assertEqual(boolean("4'b10xz & 4'b0011").bits, "00xx")
        self.assertEqual(boolean("a[3:2]", {"a": "1010"}).bits, "10")
        self.assertEqual(boolean("a[8]", {"a": "1010"}).bits, "x")
        self.assertEqual(boolean("{2'b10, 2'b01}").bits, "1001")
        self.assertEqual(boolean("&4'b11x1").bits, "x")
        self.assertEqual(boolean("^4'b1011").bits, "1")
        self.assertEqual(boolean("1'bx ? 4'b1010 : 4'b1001").bits, "10xx")
        self.assertEqual(boolean("v[4:5]", {"v": Bits("1010", lsb=7, ascending=True)}).bits, "10")
        self.assertEqual(boolean("v[7]", {"v": Bits("1000", lsb=4)}).bits, "1")

    def test_sizing_signedness_and_context_before_arithmetic(self):
        self.assertEqual(boolean("(4'b1111 + 4'b0001) == 5'b10000").bits, "1")
        self.assertEqual(boolean("4'sb1111 < 4'sb0001").bits, "1")
        self.assertEqual(boolean("4'sb1111 < 4'b0001").bits, "0")
        self.assertEqual(boolean("4'sb1000 >>> 2").bits, "1110")
        self.assertEqual(boolean("4'b1000 >>> 2").bits, "0010")
        self.assertEqual(boolean("8'b10101010 & '1").bits, "10101010")
        self.assertEqual(boolean("(-7) / 3").integer(), -2)
        self.assertEqual(boolean("(-7) % 3").integer(), -1)


if __name__ == "__main__":
    unittest.main()

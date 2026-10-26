"""M0 regression: sampling boundaries, rewriting, provenance and pilot stimuli.

No external simulator is needed by discovery. Icarus integration and the
intentionally incorrect #0 replay probe are explicit M0 CLI experiments.
"""

from dataclasses import replace
import itertools
import json
from pathlib import Path
import tempfile
import unittest

from sva_reference import m0
from sva_reference.source import UnsupportedSource, inspect_source, rewrite
from sva_reference.trace import (EDGES, Tick, Trace, TraceError, load_trace,
                                 read_vcd, save_trace)


HEADER = """$timescale 1 ns $end
$scope module top $end
$var reg 1 ! clk $end
$var reg 4 \" data [3:0] $end
$scope module child $end
$var wire 4 \" alias [3:0] $end
$upscope $end
$upscope $end
$enddefinitions $end
"""


class TraceTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.path = Path(self.tmp.name) / "input.vcd"

    def read(self, changes, **kwargs):
        self.path.write_text(HEADER + changes)
        return read_vcd(self.path, "top.clk", ["top.data", "top.child.alias"], **kwargs)

    def test_sampling_excludes_entire_timestamp_in_any_vcd_order(self):
        # 16.5.1: a same-time data write must never enter the sampled value.
        for changes in itertools.permutations(['1!', 'b10 "']):
            trace = self.read('#0\n$dumpvars\n0!\nb1 "\n$end\n#5\n'
                              + '\n'.join(changes) + '\n#10\n0!\n#15\n1!\n')
            self.assertEqual([t.time for t in trace.ticks], [5, 15])
            self.assertEqual(trace.ticks[0].sampled,
                             {"top.data": "0001", "top.child.alias": "0001"})
            self.assertEqual(trace.ticks[0].settled["top.data"], "0010")
            self.assertEqual(trace.ticks[1].sampled["top.data"], "0010")
            self.assertEqual(trace.end_time, 15)

    def test_vector_extension_follows_table_21_8(self):
        for short, full in [("1", "0001"), ("0", "0000"), ("X10", "xx10"),
                            ("ZX0", "zzx0"), ("0X10", "0x10")]:
            with self.subTest(short=short):
                trace = self.read(f'#0\n0!\nb{short} "\n#5\n1!\n')
                self.assertEqual(trace.ticks[0].sampled["top.data"], full)

    def test_four_state_edges_follow_9_4_2(self):
        for edge, pairs in EDGES.items():
            for old, new in pairs:
                with self.subTest(edge=edge, old=old, new=new):
                    # At time zero the clock is x -> 0/1, so initialize via x
                    # at time 1 and put the pair under test at times 2 and 3.
                    self.path.write_text(HEADER + f'#0\nx!\nb0 "\n#2\n{old}!\n#3\n{new}!\n')
                    trace = read_vcd(self.path, "top.clk", ["top.data"], edge)
                    self.assertEqual(trace.ticks[-1].time, 3)

    def test_duplicate_timestamps_are_one_sampling_batch(self):
        trace = self.read('#0\n0!\nb0 "\n#5\nb1 "\n#5\n1!\n')
        self.assertEqual(trace.ticks[0].sampled["top.data"], "0000")
        self.assertEqual(trace.ticks[0].settled["top.data"], "0001")

    def test_unrepresentable_or_missing_inputs_fail_closed(self):
        for changes, message in [('#0\n1!\n', "time-zero"),
                                 ('#0\n0!\n#5\n1!\n0!\n', "multiple clock"),
                                 ('#0\n0!\n#5\n$dumpoff\n', "dump gaps"),
                                 ('#0\n0!\n#5\nb10101 "\n1!\n', "invalid 4-bit"),
                                 ('#0\n0!\n#5\n1!\n#3\n', "not monotonic"),
                                 ('#0\n0!\n#5\n0!\n', "no selected")]:
            with self.subTest(message=message), self.assertRaisesRegex(TraceError, message):
                self.read(changes)
        self.path.write_text(HEADER + '#0\n0!\n#5\n1!\n')
        with self.assertRaisesRegex(TraceError, "exact hierarchical"):
            read_vcd(self.path, "clk", ["top.data"])
        self.path.write_text(HEADER.replace("reg 1 !", "reg 4 !") + '#0\n0!\n#5\n1!\n')
        with self.assertRaisesRegex(TraceError, "clock must be scalar"):
            read_vcd(self.path, "top.clk", ["top.data"])

    def test_real_samples_are_rejected_but_unselected_reals_are_ignored(self):
        header = HEADER.replace('$scope module child', '$var real 1 % voltage $end\n$scope module child')
        self.path.write_text(header + '#0\n0!\nr1.25 %\nb0 "\n#5\n1!\n')
        self.assertEqual(len(read_vcd(self.path, "top.clk", ["top.data"]).ticks), 1)
        with self.assertRaisesRegex(TraceError, "not an integral"):
            read_vcd(self.path, "top.clk", ["top.voltage"])

    def test_cache_invalidates_source_clock_edge_signal_set_and_protocol(self):
        trace = self.read('#0\n0!\nb1 "\n#5\n1!\n')
        cache = Path(self.tmp.name) / "trace.json"
        signals = list(trace.widths)
        save_trace(cache, trace, b"source", signals)
        self.assertEqual(load_trace(cache, b"source", "top.clk", signals), trace)
        for args in [(b"changed", "top.clk", signals, "posedge"),
                     (b"source", "top.other", signals, "posedge"),
                     (b"source", "top.clk", signals[:1], "posedge"),
                     (b"source", "top.clk", signals, "negedge")]:
            with self.subTest(args=args), self.assertRaisesRegex(TraceError, "stale trace"):
                load_trace(cache, *args)
        data = json.loads(cache.read_text())
        data["protocol"] = "future"
        cache.write_text(json.dumps(data))
        with self.assertRaisesRegex(TraceError, "schema/protocol"):
            load_trace(cache, b"source", "top.clk", signals)


class SourceTests(unittest.TestCase):
    def test_comments_strings_nested_actions_and_fail_only_actions(self):
        source = '''module top;
          // cover property (not_code);
          initial $display("assert property (also_not_code);");
          c: cover sequence (@(posedge clk) (a ##1 b)) begin
            if (flag) begin total++; end else total--;
          end
          a: assert property (@(posedge clk) x) else begin failures++; end
          b: assume property (@(posedge clk) y) pass++; else fail++;
          endmodule'''
        top, directives = inspect_source(source)
        self.assertEqual(top, "top")
        self.assertEqual([d.label for d in directives], ["c", "a", "b"])
        self.assertEqual(directives[1].passed, ";")
        self.assertIn("failures++", directives[1].failed)
        self.assertEqual(directives[2].failed, "fail++;")
        stripped = rewrite(source)
        self.assertIn('initial $display("assert property (also_not_code);");', stripped)
        self.assertNotIn("total++", stripped)
        self.assertEqual(source.count("\n"), stripped.count("\n"))

    def test_procedural_and_unhandled_contexts_are_explicitly_rejected(self):
        for body in ['initial begin a: assert property (x); end',
                     'always a: assert property (x);',
                     'task t; a: assert property (x); endtask',
                     'sequence s; x; endsequence',
                     'generate if (1) begin c: cover property(x); end endgenerate',
                     'cover property (x);',
                     'c: cover property (x); c: cover property (x);',
                     '`include "x.svh"']:
            with self.subTest(body=body), self.assertRaises(UnsupportedSource):
                inspect_source("module m; " + body + " endmodule")

    def test_replay_preserves_multiplicity_and_action_branch(self):
        source = '`timescale 1ns/1ns\nmodule m; c: assert property (x) p++; else f++; endmodule'
        trace = Trace("1ns", "m.clk", "posedge", {}, [Tick(5, {}, {}), Tick(15, {}, {})], 20)
        _, output = m0.replay_source(source, trace, [m0.Action("c", 0, 0, "pass"),
                                                  m0.Action("c", 0, 0, "pass"),
                                                  m0.Action("c", 0, 1, "fail")])
        self.assertEqual(output.count("p++;"), 2)
        self.assertEqual(output.count("f++;"), 1)
        self.assertIn("#0; #0; p++;", output)
        self.assertIn("#10; #0; f++;", output)


class PilotTests(unittest.TestCase):
    def test_saved_traces_match_every_pilot_model_stimulus_tick_offline(self):
        results = m0.run_pilots()
        self.assertEqual([r["ticks"] for r in results], [21, 24, 25])
        self.assertTrue(all(r["a_b_match"] is None and r["expected_match"] is None
                            for r in results))

    def test_stimulus_audit_detects_one_wrong_tick(self):
        name = next(iter(m0.PILOTS))
        signals = [f"{name}.{s}" for s in m0.PILOTS[name]]
        source = (m0.ROOT / "tests/ch16" / f"{name}.sv").read_bytes()
        trace = load_trace(m0.FIXTURES / f"{name}.json", source, f"{name}.clk", signals)
        bad_tick = replace(trace.ticks[0], sampled={signal: "0" for signal in signals})
        bad_trace = replace(trace, ticks=[bad_tick, *trace.ticks[1:]])
        with self.assertRaisesRegex(TraceError, "stimulus differs at tick 1"):
            m0.audit_stimulus(name, bad_trace)

    def test_pilot_adapter_refuses_changed_source_before_using_cached_results(self):
        with self.assertRaisesRegex(TraceError, "repeat the M0 source audit"):
            m0.validate_pilot_source(next(iter(m0.PILOTS)), b"module modified; endmodule")


if __name__ == "__main__":
    unittest.main()

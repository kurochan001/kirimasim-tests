"""M2 integration regressions; simulators are not required by discovery."""

from dataclasses import replace
import json
from pathlib import Path
import tempfile
import unittest
from unittest import mock

from sva_reference import bridge, check, pilots
from sva_reference.bridge import engine_from_trace, project_stimulus, signal_types
from sva_reference.module import parse_module
from sva_reference.parser import Unsupported
from sva_reference.trace import Tick, Trace, TraceError


class TypedBridgeTests(unittest.TestCase):
    def module(self):
        return parse_module('''`timescale 1ns/1ns
        module m;
          logic clk = 0;
          wire logic [7:4] descending;
          logic signed [0:3] ascending;
          int count;
          bit flag;
          int queue[$];
          function automatic int f(logic misleading); return misleading; endfunction
          task t(logic hidden); #1; endtask
          c: cover property(@(posedge clk) ascending[0:1] == 2'b10 && descending[7]);
          initial begin #30; $finish; end
        endmodule''')

    def test_source_types_keep_width_signedness_range_and_two_state(self):
        types = signal_types(self.module())
        self.assertEqual((types["descending"].width, types["descending"].lsb), (4, 4))
        self.assertTrue(types["ascending"].ascending)
        self.assertTrue(types["ascending"].signed)
        self.assertTrue(types["count"].two_state)
        self.assertTrue(types["count"].signed)
        self.assertTrue(types["flag"].two_state)
        self.assertIsNone(types["queue"])
        self.assertNotIn("hidden", types)
        self.assertNotIn("misleading", types)

    def test_typed_trace_drives_ascending_and_nonzero_based_selections(self):
        trace = Trace("1ns", "m.clk", "posedge", {"m.ascending": 4, "m.descending": 4},
                      [Tick(5, {"m.ascending": "1010", "m.descending": "1000"}, {})], 10)
        module = self.module()
        self.assertEqual(engine_from_trace(module, trace).property(module.directives[0].spec).status, "success")
        with self.assertRaisesRegex(TraceError, "width disagrees"):
            engine_from_trace(module, replace(trace, widths={"m.ascending": 8, "m.descending": 4}))
        with self.assertRaisesRegex(TraceError, "clock/edge"):
            engine_from_trace(module, replace(trace, edge="negedge"))
        unknown = Trace("1ns", "m.clk", "posedge", {"m.flag": 1}, [Tick(5, {"m.flag": "x"}, {})], 10)
        with self.assertRaisesRegex(TraceError, "two-state"):
            engine_from_trace(module, unknown)

    def test_projection_preserves_delays_null_statements_stimulus_and_finish(self):
        module = parse_module('''`timescale 1ns/1ns
        module m;
          logic clk=0, a=0;
          int q[$];
          function automatic string times(int values[$]); return ""; endfunction
          function automatic int stimulus(int value); return value; endfunction
          c: cover sequence(@(posedge clk) a) q.push_back($time);
          initial begin
            a = stimulus(1);
            #1 $display("values:%s", times(q));
            #9;
            $finish;
          end
        endmodule''')
        projected = project_stimulus(module, remove_functions=("times",))
        self.assertNotIn("times", [t.text for t in bridge.tokens(projected)])
        self.assertIn("function automatic int stimulus", projected)
        self.assertIn("a = stimulus(1)", projected)
        self.assertRegex(projected, r"#1 ;")
        self.assertIn("#9;", projected)
        self.assertIn("$finish", projected)
        self.assertNotIn("push_back", projected)
        self.assertNotIn("cover sequence", projected)
        self.assertIn('$dumpfile("trace.vcd")', projected)

    def test_projection_refuses_removing_a_still_used_function(self):
        module = parse_module('''module m;
          logic clk, a;
          function automatic int helper(int x); return x; endfunction
          c: cover property(@(posedge clk) a);
          initial a=helper(1);
        endmodule''')
        with self.assertRaisesRegex(Unsupported, "still referenced"):
            project_stimulus(module, remove_functions=("helper",))

    def test_projection_cache_invalidates_changed_source_projection_and_metadata(self):
        source = b"module m; logic clk=0, a=1; c: cover property(@(posedge clk) a); endmodule"
        module = parse_module(source.decode())
        projected = project_stimulus(module)
        vcd = '''$timescale 1ns $end
        $scope module m $end
        $var reg 1 ! clk $end
        $var reg 1 " a $end
        $upscope $end
        $enddefinitions $end
        #0
        0!
        1"
        #5
        1!
        #10
        0!
        '''
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "trace.json"
            with mock.patch.object(bridge, "run_icarus", return_value=("", vcd)):
                trace = bridge.capture_projected(source, projected, module, ("a",), "unused", path)
            self.assertEqual(bridge.load_projected(path, source, projected, module, ("a",)), trace)
            for changed_source, changed_projection, changed_module in [
                (source + b"\n", projected, module),
                (source, projected + "\n", module),
                (source, projected, parse_module(source.decode().replace("logic clk", "logic signed clk")))
            ]:
                with self.subTest(source=changed_source), self.assertRaisesRegex(TraceError, "stale trace"):
                    bridge.load_projected(path, changed_source, changed_projection, changed_module, ("a",))


class PilotIntegrationTests(unittest.TestCase):
    def test_all_pilots_match_the_existing_suite_outputs_offline(self):
        results = check.run(list(pilots.PILOTS))
        self.assertEqual(len(results), 10)
        self.assertTrue(all(result["status"] == "match" for result in results), results)
        self.assertEqual(sum(result["ticks"] for result in results), 188)
        self.assertEqual(sum(result["actions"] for result in results), 117)

    def test_emit_only_never_reads_expectations_or_calls_m0_semantics(self):
        read_text = Path.read_text
        def guarded_read(path, *args, **kwargs):
            if path.suffix == ".expected":
                raise AssertionError("generation opened an expectation")
            return read_text(path, *args, **kwargs)
        with mock.patch.object(Path, "read_text", guarded_read), \
                mock.patch("sva_reference.m0.evaluate", side_effect=AssertionError("M0 semantics called")):
            results = check.run(list(pilots.PILOTS), emit_only=True)
        self.assertTrue(all(result["status"] == "generated" for result in results))

    def test_every_sample_matches_the_external_pilot_stimulus_inputs(self):
        evidence = json.loads((pilots.FIXTURES / "stimulus_inputs.json").read_text())
        self.assertEqual(set(evidence["models"]), set(pilots.PILOTS))
        for name, pilot in pilots.PILOTS.items():
            with self.subTest(name=name):
                cache = json.loads((pilots.FIXTURES / (name + ".json")).read_text())
                model = evidence["models"][name]
                self.assertEqual(model["signals"], list(pilot.signals))
                values = ["".join(tick["sampled"][f"{name}.{signal}"] for signal in pilot.signals)
                          for tick in cache["trace"]["ticks"]]
                self.assertEqual(values, model["samples"])

    def test_generate_all_precedes_comparison_and_emit_only_skips_comparison(self):
        order = []
        def generate(name, **kwargs):
            order.append(("generate", name))
            return name
        def compare(name):
            order.append(("compare", name))
            return {"status": "match"}
        with mock.patch.object(check, "generate", generate), mock.patch.object(check, "compare_expected", compare):
            check.run(["one", "two"])
        self.assertEqual(order, [("generate", "one"), ("generate", "two"), ("compare", "one"), ("compare", "two")])

    def test_comparison_reports_a_difference_without_changing_expectations(self):
        result = pilots.generate("test_sequence_first_match")
        changed = replace(result, output=result.output + "extra line\n")
        report = check.compare_expected(changed)
        self.assertEqual(report["status"], "mismatch")
        self.assertIn("+extra line", report["diff"])

    def test_queue_adapter_preserves_duplicate_actions(self):
        name = "test_sequence_first_match"
        generated = pilots.generate(name)
        twins = [event for event in generated.events if event.label == "c_tie" and event.time == 75]
        self.assertEqual(len(twins), 2)
        removed = list(generated.events)
        removed.remove(twins[0])
        source = (pilots.ROOT / "tests/ch16" / (name + ".sv")).read_text()
        module = parse_module(source)
        projected = project_stimulus(module, remove_functions=("times",))
        trace = bridge.load_projected(pilots.FIXTURES / (name + ".json"), source.encode(), projected, module, pilots.PILOTS[name].signals)
        altered = pilots.render(name, source, trace, removed)
        self.assertNotEqual(altered, generated.output)
        self.assertEqual(generated.output.splitlines()[-1], "first_match of the or: 15 75 75 115")

    def test_counter_adapter_applies_phase_resets_at_report_boundaries(self):
        name = "test_property_until_strong_forms"
        source = (pilots.ROOT / "tests/ch16" / (name + ".sv")).read_text()
        module = parse_module(source)
        projected = project_stimulus(module)
        trace = bridge.load_projected(pilots.FIXTURES / (name + ".json"), source.encode(), projected, module, pilots.PILOTS[name].signals)
        events = (pilots.Event("a_su", 0, 4, 45, "fail", "f_su", "increment"),
                  pilots.Event("a_su", 5, 5, 55, "fail", "f_su", "increment"))
        output = pilots.render(name, source, trace, events)
        counts = [line.split("a_su ", 1)[1].split(",", 1)[0] for line in output.splitlines()]
        self.assertEqual(counts, ["1", "1", "0", "0"])

    def test_unknown_actions_sources_and_report_collisions_fail_closed(self):
        with self.assertRaisesRegex(Unsupported, "new adapter"):
            pilots._action("a = compute();")
        with self.assertRaisesRegex(Unsupported, "audit"):
            pilots.audit_source("test_sequence_first_match", b"changed")
        name = "test_sequence_first_match"
        generated = pilots.generate(name)
        source = (pilots.ROOT / "tests/ch16" / (name + ".sv")).read_text()
        module = parse_module(source)
        projected = project_stimulus(module, remove_functions=("times",))
        trace = bridge.load_projected(pilots.FIXTURES / (name + ".json"), source.encode(), projected, module, pilots.PILOTS[name].signals)
        event = replace(generated.events[0], time=trace.end_time)
        with self.assertRaisesRegex(Unsupported, "action/report collision"):
            pilots.render(name, source, trace, (event,))

    def test_output_artifacts_contain_independently_generated_stdout_and_events(self):
        with tempfile.TemporaryDirectory() as directory:
            name = "test_sequence_first_match"
            check.run([name], emit_only=True, output_dir=directory)
            root = Path(directory)
            self.assertEqual((root / (name + ".actual")).read_text(), pilots.generate(name).output)
            events = json.loads((root / (name + ".events.json")).read_text())
            self.assertEqual(len(events["events"]), 15)
            self.assertEqual(events["attempts"]["c_tie"]["matches"], 4)


if __name__ == "__main__":
    unittest.main()

/*
:name: test_switch_unknown_control_same_value_resolution
:description: An unknown switch control preserves agreement but yields unknown for competing source values (IEEE 1800-2023 Section 4.9.5)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.9.5 28.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_switch_unknown_control_same_value_resolution.expected
*/
// IEEE 1800-2023 4.9.5 28.8: Each conditional pass path may be on or off; equal
// source and destination drives agree in both cases, while opposing drives do
// not.
// Oracle checks: The 5.052 release is a two-state engine and is not used as the
// oracle here.

module test_switch_unknown_control_same_value_resolution;
  supply1 source;
  tri agree, conflict;
  pullup (agree);
  pulldown (conflict);
  tranif1 first(agree, source, 1'bx);
  tranif1 second(conflict, source, 1'bx);
  initial #1 $display("agree=%b conflict=%b", agree, conflict);
endmodule

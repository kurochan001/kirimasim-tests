/*
:name: test_illegal_always_comb_event_control
:description: An always_comb procedure cannot contain an event control (IEEE 1800-2023 Section 9.2.2.2.2)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.2.2.2.2 9.2.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the always_comb procedure has an event control
:expected_stderr_regex: test_illegal_always_comb_event_control\.sv:23:
*/
// IEEE 1800-2023 §9.2.2.2.2: the statements of an always_comb procedure shall
// not include blocking timing or event controls; its sensitivity is inferred.
// The design is accepted by Verilator 5.052 (docs/simulator-differences.md).

`timescale 1ns/1ns

module test_illegal_always_comb_event_control;
  logic a = 0, b = 0, y;
  always_comb begin
    @(b);   // illegal: event control in always_comb
    y = a;
  end
  initial #5 $display("y=%b", y);
endmodule

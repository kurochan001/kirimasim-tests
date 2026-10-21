/*
:name: test_illegal_always_comb_delay
:description: An always_comb procedure cannot contain a delay (IEEE 1800-2023 Section 9.2.2.2.2)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.2.2.2.2 9.2.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the always_comb procedure has a delay control
:expected_stderr_regex: test_illegal_always_comb_delay\.sv:24:
*/
// IEEE 1800-2023 §9.2.2.2.2: the statements of an always_comb procedure shall
// not include those that block, have blocking timing or event controls, or
// fork-join statements.
// The design is accepted by Verilator 5.052 (docs/simulator-differences.md).

`timescale 1ns/1ns

module test_illegal_always_comb_delay;
  logic a = 0, y;
  always_comb begin
    #1 y = a;   // illegal: delay in always_comb
  end
  initial #5 $display("y=%b", y);
endmodule

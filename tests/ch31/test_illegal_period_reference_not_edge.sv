/*
:name: test_illegal_period_reference_not_edge
:description: The reference event of $period has to be an edge (IEEE 1800-2023 Section 31.4.5)
:tags: ch31
:type: elaboration
:lrm: 1800-2023 31.4.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the reference event of $period has no edge
:expected_stderr_regex: test_illegal_period_reference_not_edge\.sv:24:
*/
// IEEE 1800-2023 §31.4.5: a compilation error shall occur if the reference
// event of $period is not an edge specification.
// Icarus Verilog 13.0 and Verilator 5.052 accept the design
// (docs/simulator-differences.md).

`timescale 1ns/1ns

module timing_period_no_edge(input clk);
  reg n = 0;
  specify
    $period(clk, 10, n);   // illegal: no edge
  endspecify
endmodule

module test_illegal_period_reference_not_edge;
  reg clk = 0;
  timing_period_no_edge u(clk);
  initial #10 clk = 1;
endmodule

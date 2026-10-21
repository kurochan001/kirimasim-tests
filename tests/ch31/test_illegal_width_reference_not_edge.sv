/*
:name: test_illegal_width_reference_not_edge
:description: The reference event of $width has to be an edge (IEEE 1800-2023 Section 31.4.4)
:tags: ch31
:type: elaboration
:lrm: 1800-2023 31.4.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the reference event of $width has no edge
:expected_stderr_regex: test_illegal_width_reference_not_edge\.sv:25:
*/
// IEEE 1800-2023 §31.4.4: $width derives its data event from the opposite
// edge of its reference event, and a compilation error shall occur if the
// reference event is not an edge specification.
// Icarus Verilog 13.0 and Verilator 5.052 accept the design
// (docs/simulator-differences.md).

`timescale 1ns/1ns

module timing_width_no_edge(input clk);
  reg n = 0;
  specify
    $width(clk, 5, 0, n);   // illegal: no edge
  endspecify
endmodule

module test_illegal_width_reference_not_edge;
  reg clk = 0;
  timing_width_no_edge u(clk);
  initial #10 clk = 1;
endmodule

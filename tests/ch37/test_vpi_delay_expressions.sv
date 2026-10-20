/*
:name: test_vpi_delay_expressions
:description: vpiDelay gives the delay expression written in the source: a constant for a single delay, and an operation of type vpiListOp with the delays as operands for several (IEEE 1800-2023 Section 37.3.4)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.4 37.75 37.80
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_delay_expressions.c
:expected_stdout: @test_vpi_delay_expressions.expected
*/
// IEEE 1800-2023 §37.3.4: nets, primitives, module paths, timing checks and
// continuous assignments can have delays in the source, which vpiDelay returns:
// an expression that evaluates to a constant for one delay, or an operation
// whose vpiOpType is vpiListOp for several. g1 has two delays, g2 one, and the
// continuous assignment one. The primitives (37.80) are sorted by name; the
// continuous assignment (37.75) is the only one.

`timescale 1ns/1ns

module test_vpi_delay_expressions;
  logic a = 0, b = 1;
  wire y1, y2, y3;

  and #(2, 3) g1 (y1, a, b);
  buf #5 g2 (y2, a);
  assign #4 y3 = a;

  initial #10 $vt_delays;
endmodule

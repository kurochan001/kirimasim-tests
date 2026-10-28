/*
:name: test_real_operand_result_types
:description: Logical and relational operators and inside give a single bit even for real operands; other operators give a real result when any operand is real and a shortreal one when an operand is shortreal, except for the condition of ?: (IEEE 1800-2023 Section 11.3.1)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.1 6.12 11.4.13 20.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_operand_result_types.expected
*/
// IEEE 1800-2023 §11.3.1: logical and relational operators and inside give a
// single-bit result for real operands. For the other operators the result is
// real if any operand is real, or else shortreal if any operand is shortreal;
// the condition before ? does not count. $bits (20.6.2) shows the integral
// widths: 1 for the bits and 32 for c ? 3 : 4, whose only real is the
// condition. $bits is not used on the real results, because real and
// shortreal are not bit-stream types (6.24.3); their values show the type:
//   r + i is 3.50, which an integral result cannot hold;
//   s * t is 0.2000000000 in real, 0.2000000030 if it were shortreal;
//   big + j is 16777216.0 in shortreal, 16777217.0 if it were real;
//   (1 ? 3 : 2.5) / 2 is 1.5 in real, 1.0 if the branch stayed integral.
//
// In Verilator 5.052 shortreal is kept and computed as real, so big + j
// gives 16777217.0 there. Icarus Verilog 13.0 does not support inside.

module test_real_operand_result_types;
  real r = 1.5, c = 0.25, t = 0.1;
  shortreal s = 2.0, big = 16777216.0;
  int i = 2, j = 1;

  initial begin
    $display("bits: %0d %0d %0d", $bits(r < 2.0), $bits(r && c), $bits(r inside {1.5, 2.5}));
    $display("values: %b %b %b", r < 2.0, r && c, r inside {1.5, 2.5});
    $display("real: %.2f %.10f, shortreal: %.1f", r + i, s * t, big + j);
    $display("condition only: %0d, branches: %.1f", $bits(c ? 3 : 4), (1 ? 3 : 2.5) / 2);
  end
endmodule

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
// the condition before ? does not count. $bits (20.6.2) shows the widths: 1
// for the bits, 64 for real, 32 for shortreal, and 32 for c ? 3 : 4, whose
// only real is the condition. 1 ? 3 : 2.5 is real, so it shows 3.0.
//
// In Verilator 5.052 shortreal is real, so s + i gives 64.

module test_real_operand_result_types;
  real r = 1.5, c = 0.25;
  shortreal s = 2.0;
  int i = 2;

  initial begin
    $display("bits: %0d %0d %0d", $bits(r < 2.0), $bits(r && c), $bits(r inside {1.5, 2.5}));
    $display("values: %b %b %b", r < 2.0, r && c, r inside {1.5, 2.5});
    $display("real: %0d %0d, shortreal: %0d", $bits(r + i), $bits(s * r), $bits(s + i));
    $display("condition only: %0d, branches: %0d %.1f", $bits(c ? 3 : 4), $bits(1 ? 3 : 2.5),
             1 ? 3 : 2.5);
  end
endmodule

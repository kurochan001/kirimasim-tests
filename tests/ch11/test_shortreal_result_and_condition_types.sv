/*
:name: test_shortreal_result_and_condition_types
:description: Observe shortreal arithmetic promotion and the conditional-control exception
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.1 6.12 20.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_shortreal_result_and_condition_types.expected
*/
// IEEE 11.3.1: shortreal promotes other arithmetic operands unless a
// real operand takes priority. A shortreal control alone must not change
// four-bit integral branch type. A mistaken promotion would give 32 bits.
// The result widths are queried before assignment.
// Expected widths follow the standard even if a tool promotes shortreal
// to real or rejects shortreal-valued conditional expressions.
// Icarus 13.0 reports one-bit arithmetic expressions here.
// In Verilator 5.052, shortreal arithmetic instead has 64-bit real width.
module test_shortreal_result_and_condition_types;
  shortreal s = 1.5;
  int i = 2;
  real r = 0.25;
  logic [3:0] nibble = 4'd2;
  initial begin
    $display("arithmetic_bits=%0d %0d real_mix=%0d",
             $bits(s+i), $bits(i*s), $bits(s+r));
    $display("conditional_bits=%0d %0d control_only=%0d",
             $bits(1 ? s : i), $bits(0 ? i : s), $bits(s ? nibble : 4'd3));
    $display("values=%.2f %.2f %.2f control=%0d", s+i, i*s, s+r, s ? i : 3);
    $finish;
  end
endmodule

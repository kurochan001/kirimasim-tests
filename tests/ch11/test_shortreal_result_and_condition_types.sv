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
// four-bit integral branch type; $bits (20.6.2) shows that width, and a
// mistaken promotion would give a shortreal, which has no $bits.
// $bits is not used on the real-valued results, because real and
// shortreal are not bit-stream types (6.24.3); the rounding shows the type:
//   big + one is 16777216.0 in shortreal, 16777217.0 in real;
//   three * t is 0.3000000119 in shortreal, 0.3000000045 in real;
//   big + r1 is 16777217.0, because the real operand takes priority;
//   (1 ? s : one) * t is 0.1500000060 when the branches give a shortreal,
//   0.1500000022 if they gave a real, 0.2000000030 if they gave an int.
//
// Icarus Verilog 13.0 and Verilator 5.052 keep and compute shortreal as
// real, so they print 16777217.0, 0.3000000000 and 0.1500000000 for the
// shortreal results.
module test_shortreal_result_and_condition_types;
  shortreal s = 1.5, t = 0.1, big = 16777216.0;
  int i = 2, one = 1, three = 3;
  real r1 = 1.0;
  logic [3:0] nibble = 4'd2;
  initial begin
    $display("arithmetic=%.1f %.10f real_mix=%.1f", big + one, three * t, big + r1);
    $display("conditional=%.10f %.10f control_only=%0d",
             (1 ? s : one) * t, (0 ? one : s) * t, $bits(s ? nibble : 4'd3));
    $display("values=%.2f %.2f control=%0d", s+i, i*s, s ? i : 3);
    $finish;
  end
endmodule

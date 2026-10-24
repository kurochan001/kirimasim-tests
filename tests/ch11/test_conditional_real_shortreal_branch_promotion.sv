/*
:name: test_conditional_real_shortreal_branch_promotion
:description: a real branch of a conditional expression makes the result real and converts a shortreal or integral other branch, and a shortreal branch with an integral one makes it shortreal (IEEE 1800-2023 Section 11.4.11)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11 6.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_conditional_real_shortreal_branch_promotion.expected
*/
// IEEE 1800-2023 §11.4.11: if one branch of ?: is real and the other is
// shortreal or integral, the other is cast to real and the result is real;
// if one is shortreal and the other integral, the integral one is cast to
// shortreal and the result is shortreal.
// (1 ? 7 : 2.5) / 2 divides a real (3.5, not 3), and (0 ? s : 3) / 2 a
// shortreal (1.5, not 1). The real branch 1 + 2**-30 keeps its last bit when
// the other branch is shortreal (1.0 after subtracting 1 and scaling by
// 2**30), which a shortreal result would lose (0.0). The integral 16777217 is
// 2**24 + 1: against a shortreal branch it becomes the shortreal 16777216,
// against a real branch it stays 16777217. A shortreal is a single
// precision value, like a C float (§6.12).
// Icarus Verilog 13.0 and Verilator 5.052 keep shortreal values in double
// precision, so they print 16777217.0 for the shortreal result as well.

module test_conditional_real_shortreal_branch_promotion;
  bit t = 1, f = 0;
  real rb, x1, x2, x3, x4, x5;
  shortreal s = 3.0;

  initial begin
    rb = 1.0 + 2.0 ** -30;
    x1 = (t ? 7 : 2.5) / 2;
    x2 = (f ? s : 3) / 2;
    x3 = ((t ? rb : s) - 1.0) * 2.0 ** 30;
    x4 = f ? s : 16777217;
    x5 = f ? rb : 16777217;
    $display("%0.1f %0.1f %0.1f %0.1f %0.1f", x1, x2, x3, x4, x5);
  end
endmodule

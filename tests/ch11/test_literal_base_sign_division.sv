/*
:name: test_literal_base_sign_division
:description: An unbased integer literal is signed and a literal with an unsigned base is unsigned, which changes the result of negating and dividing it (IEEE 1800-2023 Section 11.3.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.3 11.4.3.1 11.4.3 5.7.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_literal_base_sign_division.expected
*/
// IEEE 1800-2023 §11.3.3: an integer literal without a base is a signed value,
// while one with a base and no s is unsigned. So -'d20 / 5 is computed on the
// unsigned 32-bit value 2**32 - 20, while -20 / 5 and -'sd20 / 5 are -4. A
// sized signed literal that does not fit its width keeps only its bits:
// 5'sd20 is 5'b10100, which is -12. §11.4.3.1: a signed variable is divided as
// a signed value and an unsigned one as an unsigned value, and §11.4.3 integer
// division truncates toward zero.

module test_literal_base_sign_division;
  int r1, r2, r3, r4;
  logic [7:0] u;
  logic signed [7:0] s;

  initial begin
    r1 = -20 / 5;
    r2 = -'d20 / 5;
    r3 = -'sd20 / 5;
    r4 = -5'sd20 / 5;
    $display("r1=%0d r2=%0d r3=%0d r4=%0d", r1, r2, r3, r4);
    u = -8'sd3;
    s = -8'sd3;
    $display("u=%0d u/2=%0d s=%0d s/2=%0d", u, u / 2, s, s / 2);
  end
endmodule

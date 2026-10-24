/*
:name: test_power_minus_one_one_zero_exponent_and_real
:description: an integral -1 to a positive power is -1 for an odd and 1 for an even exponent, any integral base to the power 0 is 1, and a real operand of ** makes the result real (IEEE 1800-2023 Section 11.4.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_power_minus_one_one_zero_exponent_and_real.expected
*/
// IEEE 1800-2023 §11.4.3, Table 11-4: for integral operands, -1 ** n is -1
// when n is odd and 1 when n is even, and op1 ** 0 is 1 for every op1,
// including -1, 0 and 1. The size and sign of the result follow the operands
// and the context (§11.6.1, §11.8.1). If either operand is real, the result
// is real.
// The exponents include a large odd and a large even value, so the result
// has to follow the parity of the exponent. The 4-bit signed -1 is extended
// to the 8-bit context first, so -1 ** 3 is 8'hff (255 in the unsigned
// target) and -1 ** 2 is 1. The unsigned 4'b1111 is 15, not
// -1, so its square is 225. With a real operand the result keeps its
// fraction: 2 ** -1.0 is 0.5 where the integral rule would give 0, and
// 2.0 ** 3 is 8.0 divided by 16 as 0.5, not 0.

module test_power_minus_one_one_zero_exponent_and_real;
  int m1 = -1, one = 1, zero = 0, five = 5;
  int odd = 1000001, even = 1000000;
  logic signed [3:0] s4 = -4'sd1;
  logic [3:0] u4 = 4'b1111;
  logic [7:0] u8a, u8b, u8c;
  real r1, r2, r3, r4;

  initial begin
    $display("-1 ** 3 = %0d, -1 ** 4 = %0d", m1 ** 3, m1 ** 4);
    $display("-1 ** 1000001 = %0d, -1 ** 1000000 = %0d", m1 ** odd, m1 ** even);
    u8a = s4 ** 3;
    u8b = s4 ** 2;
    u8c = u4 ** 2;
    $display("8-bit context: %0d %0d %0d", u8a, u8b, u8c);
    $display("-1 ** 0 = %0d, 1 ** 0 = %0d, 0 ** 0 = %0d, 5 ** 0 = %0d", m1 ** 0, one ** 0,
             zero ** 0, five ** 0);
    r1 = 2 ** -1.0;
    r2 = 2.0 ** 3 / 16;
    r3 = 9 ** 0.5;
    r4 = 2 ** -1;
    $display("real: %0.3f %0.3f %0.3f, integral: %0.3f", r1, r2, r3, r4);
  end
endmodule

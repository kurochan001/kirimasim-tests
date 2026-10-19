/*
:name: test_arithmetic_wider_than_64_bits
:description: Multiplication, division, modulus, relational operators, power and $clog2 on 96-bit operands (IEEE 1800-2023 Section 11.4.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.4.4 20.8.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_arithmetic_wider_than_64_bits.expected
*/
// IEEE 1800-2023 §11.4.3: the arithmetic operators work on the whole width
// of their operands, also beyond 64 bits; division truncates toward zero and
// the modulus takes the sign of the first operand. §11.4.4: so do the
// relational operators. §20.8.1: $clog2 gives the ceiling of the base-2
// logarithm of its whole argument.

module test_arithmetic_wider_than_64_bits;
  logic [95:0] a, b;
  logic signed [95:0] sa, sb;

  initial begin
    a = {32'd1, 64'd3};          // 2**64 + 3
    b = 96'd5;
    $display("a * b = %h", a * b);
    $display("a / b = %h", a / b);
    $display("a %% b = %0d", a % b);
    $display("a > b: %0d, a < b: %0d, a >= b: %0d, a <= b: %0d", a > b, a < b, a >= b, a <= b);
    sa = -96'sd6;
    sb = 96'sd4;
    $display("sa * sb = %0d, sa / sb = %0d, sa %% sb = %0d", sa * sb, sa / sb, sa % sb);
    $display("sa < sb: %0d", sa < sb);
    b = 96'd2;
    $display("2 ** 70 = %h", b ** 70);
    a = 96'd1 << 80;
    $display("$clog2(2**80) = %0d, $clog2(2**80 + 1) = %0d", $clog2(a), $clog2(a + 1));
  end
endmodule

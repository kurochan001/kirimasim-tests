/*
:name: test_real_shortreal_operands_of_arithmetic_logical_relational
:description: the arithmetic, arithmetic assignment, increment and decrement, logical and relational operators accept integral, real and shortreal operands, a real step of ++ and -- is 1.0, and a relational operator with one real operand compares in real (IEEE 1800-2023 Section 11.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3 11.3.1 11.4.2 11.4.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_shortreal_operands_of_arithmetic_logical_relational.expected
*/
// IEEE 1800-2023 §11.3, Table 11-1: binary + - * / **, unary + -, += -= *= /=,
// ++ --, !, && || -> <-> and < <= > >= take integral, real and shortreal
// operands. §11.3.1: with a real operand the result of an arithmetic
// operator is real, with shortreal operands only it is shortreal, and the
// logical and relational operators give one bit. §11.4.2: ++ and -- change a
// real or shortreal operand by 1.0. §11.4.4: when one operand of a
// relational operator is real, the other is converted to real first.
// Each group of lines applies the operators to int, real and shortreal
// variables. The real values are sums of powers of two, so they are exact and
// print the same with any rounding. The integral lines show the integral
// meaning (7 / 2 is 3), the real ones keep fractions (1.75 / 0.375 after /=,
// 2.25 + 1.0 = 3.25 for ++). The comparisons of the int k = 2 with 2.25 and
// 1.75, of the byte -1 with -1.5 and of the 4-bit 15 with 15.5 give the real
// result; converting the real operand to an integer by truncation or by
// rounding would change at least one of them.

module test_real_shortreal_operands_of_arithmetic_logical_relational;
  int i = 7, k = 2;
  real r = 2.5, rz = 0.0;
  shortreal s = 1.5, s2 = 0.5, s3 = 2.0, sz = 0.0;
  int ia = 10;
  real ra = 1.5;
  shortreal sa = 2.0;
  int ii = 5;
  real rr = 2.25;
  shortreal ss = -0.5;
  byte sb = -1;
  logic [3:0] u4 = 4'd15;

  initial begin
    $display("int: %0d %0d %0d %0d %0d", i + 2, i - 2, i * 2, i / 2, i ** 2);
    $display("real: %0.3f %0.3f %0.3f %0.3f %0.3f", r + 1.25, r - 0.5, r * 2.0, r / 2.0,
             r ** 2.0);
    $display("shortreal: %0.3f %0.3f %0.3f %0.3f %0.3f", s + s2, s - s2, s * s2, s / s2,
             s ** s3);
    $display("int and real: %0.3f", i / 2.0);
    $display("unary: %0d %0d %0.3f %0.3f %0.3f %0.3f", -i, +i, -r, +r, -s, +s);
    ia += 3;
    $write("int op=: %0d", ia);
    ia -= 4;
    $write(" %0d", ia);
    ia *= 2;
    $write(" %0d", ia);
    ia /= 4;
    $display(" %0d", ia);
    ra += 0.25;
    $write("real op=: %0.3f", ra);
    ra -= 1.0;
    $write(" %0.3f", ra);
    ra *= 4.0;
    $write(" %0.3f", ra);
    ra /= 8.0;
    $display(" %0.3f", ra);
    sa += 0.5;
    $write("shortreal op=: %0.3f", sa);
    sa -= 1.25;
    $write(" %0.3f", sa);
    sa *= 2.0;
    $write(" %0.3f", sa);
    sa /= 4.0;
    $display(" %0.3f", sa);
    ++ii;
    $write("int ++ --: %0d", ii);
    --ii;
    $display(" %0d", ii);
    rr++;
    $write("real ++ --: %0.3f", rr);
    --rr;
    $write(" %0.3f", rr);
    rr--;
    $write(" %0.3f", rr);
    ++rr;
    $display(" %0.3f", rr);
    ss++;
    $write("shortreal ++ --: %0.3f", ss);
    ss--;
    $display(" %0.3f", ss);
    $display("!: %b %b %b %b %b %b", !i, !0, !r, !rz, !s, !sz);
    $display("logical int: %b %b %b %b", i && 0, i || 0, 0 -> i, i <-> 0);
    $display("logical real: %b %b %b %b %b %b", r && rz, r || rz, rz -> r, r -> rz, r <-> s,
             rz <-> s);
    $display("logical shortreal: %b %b %b %b", s && s2, sz || sz, sz -> s, s <-> sz);
    $display("relational int: %b %b %b %b", i < 8, i <= 6, i > 6, i >= 8);
    $display("relational real: %b %b %b %b", r < 2.75, r <= 2.5, r > 2.5, r >= 3.0);
    $display("relational shortreal: %b %b %b %b", s < s2, s <= s, s > s2, s >= s3);
    $display("int vs real: %b %b %b %b", k < 2.25, k >= 2.25, k > 1.75, k <= 1.75);
    $display("byte, 4-bit vs real: %b %b %b", sb > -1.5, u4 < 15.5, u4 > 14.5);
    $display("bits: %0d %0d %0d", $bits(r < 2.75), $bits(!r), $bits(r && s));
  end
endmodule

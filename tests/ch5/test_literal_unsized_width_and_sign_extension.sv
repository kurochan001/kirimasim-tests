/*
:name: test_literal_unsized_width_and_sign_extension
:description: An unsized literal has at least 32 bits and as many more as its value and sign need, an integer literal is a logic vector [n-1:0] with its signedness, a sized signed or negative literal is sign extended into an unsigned or signed logic target, and a plain decimal may have a unary sign (IEEE 1800-2023 Section 5.7.1)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7.1 6.20.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_literal_unsized_width_and_sign_extension.expected
*/
// IEEE 1800-2023 §5.7.1: an unsized literal, a simple decimal number or a
// based one without a size, has at least 32 bits; one whose value needs more
// has at least the width of the value, with a sign bit when it is signed. A
// simple decimal number may start with a unary plus or minus. An integer
// literal is a vector of type logic with range [n-1:0], signed when the
// literal is signed. Sized negative and sized signed literals are sign
// extended when assigned to a logic object, whether or not that object is
// signed.
// Line "unsized" prints whether $bits of unsized decimal, hexadecimal, octal
// and binary literals is at least 32 (it need not be exactly 32). Line "wide"
// prints 'h5_0000_0001, which needs 35 bits, and the signed 6000000000, which
// needs 33 bits and a sign bit: it stays positive and keeps its value. Line
// "plain" prints simple decimals with a unary minus, a unary plus and
// leading zeros. A parameter without a type takes the type of its value
// (§6.20.2), so P = 4'b1x0z shows the range [3:0] of the literal and keeps
// x and z, and PS = 4'sb1010 is signed. Lines "sext" assign sized literals
// to an unsigned and a signed 8-bit logic: the signed 4'sb1010 and the
// negative -4'd6 fill the upper bits with ones, the unsigned 4'b1010 and the
// signed 4'sb0101 with zeros.
// The release 5.052 of Verilator keeps only 32 bits of the unsized
// 6000000000, which §5.7.1 does not allow.

module test_literal_unsized_width_and_sign_extension;
  parameter P = 4'b1x0z;
  parameter PS = 4'sb1010;
  logic [7:0] u8;
  logic signed [7:0] s8;

  initial begin
    $display("unsized: %0d %0d %0d %0d", $bits(7) >= 32, $bits('h7) >= 32, $bits('o7) >= 32,
             $bits('b1) >= 32);
    $display("wide: %h %0d %0d %0d %0d", 'h5_0000_0001, $bits('h5_0000_0001) >= 35,
             6000000000, 6000000000 > 0, $bits(6000000000) >= 34);
    $display("plain: %0d %0d %0d %0d", -12, +12, 0012, -12 / 5);
    $display("literal type: left=%0d right=%0d value=%b PS=%0d bits=%0d", $left(P), $right(P), P,
             PS, $bits(PS));
    u8 = 4'sb1010;
    s8 = 4'sb1010;
    $display("sext signed: %b %b", u8, s8);
    u8 = -4'd6;
    s8 = -4'd6;
    $display("sext negative: %b %b", u8, s8);
    u8 = 4'b1010;
    s8 = 4'b1010;
    $display("zext unsigned: %b %b", u8, s8);
    u8 = 4'sb0101;
    s8 = 4'sb0101;
    $display("sext positive: %b %b", u8, s8);
  end
endmodule

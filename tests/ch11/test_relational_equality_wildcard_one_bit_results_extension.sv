/*
:name: test_relational_equality_wildcard_one_bit_results_extension
:description: relational, equality and wildcard equality operators give a 1-bit 1, 0 or x, a relational result is x as soon as an operand has an x or z bit, and operands of unequal width are sign-extended when both are signed and zero-extended otherwise (IEEE 1800-2023 Section 11.4.5)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.5 11.4.4 11.4.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_relational_equality_wildcard_one_bit_results_extension.expected
*/
// IEEE 1800-2023 §11.4.4: < <= > >= give 1'b1 or 1'b0, and 1'bx when either
// operand has an x or z bit, even where the other bits would decide.
// §11.4.5: == != === !== compare bit for bit and give 1'b1 or 1'b0; == and !=
// give 1'bx only when x or z bits leave the relation open, === and !== never.
// When both operands are signed, the shorter one is sign-extended, otherwise
// it is zero-extended. §11.4.6: ==? and !=? give a self-determined 1-bit
// 1, 0 or x and extend their operands as == does.
// 4'b1x00 > 4'b0001 is x although bit 3 alone makes it larger. 4'b1x00 ==
// 4'b0100 is 0, since bit 3 differs, but 4'b1x00 == 4'b1100 is x. 4'sb1111
// equals 8'shff (both signed, -1) and not 8'sh0f; against the unsigned 8'h0f
// it is zero-extended and equal. 8'hfd ==? 4'sb1x01 is 0 (the unsigned left
// side makes the right zero-extended), and 1 against 8'shfd. $bits gives the
// width of each result.

module test_relational_equality_wildcard_one_bit_results_extension;
  initial begin
    $display("relational: %b %b %b %b %b %b", 4'd3 < 4'd5, 4'd5 < 4'd3, 4'b1x00 > 4'b0001,
             4'b001z <= 4'b1111, 4'b0110 >= 4'bx000, 4'd7 <= 4'd7);
    $display("== != === !==: %b %b %b %b", 4'd9 == 4'd9, 4'd9 != 4'd9, 4'd9 === 4'd8,
             4'd9 !== 4'd8);
    $display("ambiguous ==: %b %b %b %b", 4'b1x00 == 4'b0100, 4'b1x00 == 4'b1100,
             4'b1z00 != 4'b1100, 4'b0z00 != 4'b1100);
    $display("=== with x z: %b %b %b", 4'b1x0z === 4'b1x0z, 4'b1x0z === 4'b1z0x,
             4'b1x0z !== 4'b1x01);
    $display("both signed: %b %b %b", 4'sb1111 == 8'shff, 4'sb1111 == 8'sh0f,
             4'sb1000 === 8'shf8);
    $display("one unsigned: %b %b %b", 4'sb1111 == 8'h0f, 4'sb1111 == 8'hff,
             4'b1111 != 8'shff);
    $display("wildcard: %b %b %b %b %b %b", 8'hfd ==? 4'sb1x01, 8'shfd ==? 4'sb1x01,
             4'b1x01 ==? 4'b1101, 4'b1001 ==? 4'b1x01, 4'b1011 !=? 4'b1x01,
             4'b1101 !=? 4'b1x01);
    $display("bits: %0d %0d %0d %0d", $bits(4'd3 < 8'd5), $bits(8'd1 == 4'd1),
             $bits(8'd1 !== 4'd1), $bits(8'hfd ==? 4'b1x01));
  end
endmodule

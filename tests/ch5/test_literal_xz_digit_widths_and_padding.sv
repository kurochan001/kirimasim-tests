/*
:name: test_literal_xz_digit_widths_and_padding
:description: An x, z or ? digit sets four, three or one bits in hexadecimal, octal and binary, x and z are case insensitive, a literal whose leftmost given bit is x or z is padded with it, and an unsized unsigned one is extended with it to the width of its context (IEEE 1800-2023 Section 5.7.1)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_literal_xz_digit_widths_and_padding.expected
*/
// IEEE 1800-2023 §5.7.1: an x digit sets 4 bits to x in a hexadecimal
// literal, 3 bits in an octal one and 1 bit in a binary one; a z digit, and
// the ? that is an alternative for z, set as many bits to z. The x and z
// characters may be upper or lower case. When the literal has more bits than
// its digits give, it is padded on the left with zeros, but with x or z when
// the leftmost given bit is x or z. An unsized unsigned literal whose high
// bit is x or z is extended to the size of the expression it is in.
// Each line prints the literals with %b. The x, z and ? digits sit between
// known digits, so that a digit setting the wrong number of bits moves the
// known bits. The padding lines compare a leftmost x, z and 0, and the
// unsized literals are assigned to a 40-bit variable, wider than 32 bits.

module test_literal_xz_digit_widths_and_padding;
  logic [39:0] u;

  initial begin
    $display("x digits: %b %b %b", 12'h5x5, 9'o5x5, 3'b1x1);
    $display("z digits: %b %b %b", 12'h5z5, 9'o5z5, 3'b1z1);
    $display("? digits: %b %b %b", 12'h5?5, 9'o5?5, 3'b1?1);
    $display("case: %0d %0d %b %b", 8'hX3 === 8'hx3, 8'hZ3 === 8'hz3, 4'bX0Z1, 6'oXZ);
    $display("pad: %b %b %b %b", 8'bx1, 8'bz0, 8'b10, 12'hx7);
    $display("pad octal: %b %b", 9'oz2, 9'o02);
    u = 'hx;
    $display("unsized x: %b", u);
    u = 'hz9;
    $display("unsized z: %b", u);
    u = 'b?0;
    $display("unsized ?: %b", u);
    u = 'h9;
    $display("unsized 9: %b", u);
  end
endmodule

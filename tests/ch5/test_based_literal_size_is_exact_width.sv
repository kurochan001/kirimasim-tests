/*
:name: test_based_literal_size_is_exact_width
:description: The size constant of a based literal is its exact width, also when the value digits need fewer bits, as $bits, the zero-padded %b and %h forms and a concatenation of sized literals show (IEEE 1800-2023 Section 5.7.1)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7.1
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_based_literal_size_is_exact_width.expected
*/
// IEEE 1800-2023 §5.7.1: the size constant of a based literal gives the
// exact number of bits of the literal, and a value with fewer digits is
// padded on the left with zeros. Every literal below is sized, so no line
// depends on the width of an unsized number, which the standard leaves
// open above 32 bits.
// - The bits line prints $bits of 5'd3 (the value needs 2 bits), 16'h1 and
//   65'h1 (1 bit), 3'o7 (exactly 3 bits), 1'b0 and the signed 12'sd5
//   (4 bits with a sign bit): 5 16 65 3 1 12. A width taken from the value
//   digits would print 2 for 5'd3 and 1 for 16'h1 and 65'h1, and a width
//   of at least 32 for every literal would print 32 or more in place of
//   5, 16, 3, 1 and 12.
// - The pad line prints 6'b11 with %b and 40'h1 with %h; both forms show
//   leading zeros up to the width of the value (§21.2.1.2), so 000011 and
//   0000000001 show the widths 6 and 40.
// - The cat line prints {4'd1, 4'd2, 8'd3} with %h; the parts keep their
//   sizes 4, 4 and 8, so the result is 16'h1203.

module test_based_literal_size_is_exact_width;
  initial begin
    $display("bits %0d %0d %0d %0d %0d %0d", $bits(5'd3), $bits(16'h1), $bits(65'h1),
             $bits(3'o7), $bits(1'b0), $bits(12'sd5));
    $display("pad %b %h", 6'b11, 40'h1);
    $display("cat %h", {4'd1, 4'd2, 8'd3});
  end
endmodule

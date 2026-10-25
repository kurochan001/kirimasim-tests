/*
:name: test_string_literal_packed_bytes_and_compare
:description: A string literal stored in a packed array of bytes has the encoding of the flat vector, and a literal used with a string operand is converted to a string and compared character by character (IEEE 1800-2023 Section 5.9)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.9 6.16
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_literal_packed_bytes_and_compare.expected
*/
// IEEE 1800-2023 §5.9: a string literal is a packed value of 8 bits per
// character, right justified in a packed target. A multidimensional packed
// array with 8-bit elements can hold it with the same encoding as the flat
// vector. A literal is converted to the string type when it is assigned to a
// string variable or used in an expression with a string operand, and §6.16
// compares strings character by character.
// The test stores "abcd" and "ab" in a bit [0:3][7:0] and prints its bytes,
// and compares the first with "abcd" in a flat bit [31:0]. With s = "b",
// "ab" < s and s > "ab" are 1 as string comparisons ('a' is before 'b'); the
// literals as numbers, 16'h6162 and 8'h62, would compare the other way.
// Concatenating s with "cd" gives the string "bcd" of length 3.

module test_string_literal_packed_bytes_and_compare;
  typedef bit [0:3][7:0] grid_t;

  grid_t g4, g2;
  bit [31:0] flat;
  string s;

  initial begin
    g4 = "abcd";
    flat = "abcd";
    g2 = "ab";
    $display("grid4: %h %h %h %h same_as_flat=%0d", g4[0], g4[1], g4[2], g4[3], g4 == flat);
    $display("grid2: %h %h %h %h", g2[0], g2[1], g2[2], g2[3]);
    s = "b";
    $display("string compare: %0d %0d", "ab" < s, s > "ab");
    s = {s, "cd"};
    $display("concat: %s len=%0d", s, s.len());
  end
endmodule

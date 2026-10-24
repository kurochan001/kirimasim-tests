/*
:name: test_string_literal_operands_as_numbers
:description: string literal operands act as one number of 8-bit character codes under arithmetic, relational, equality, shift and bitwise operators, and a literal assigned to a wider vector is padded on the left with zeros like an unsigned value (IEEE 1800-2023 Section 11.10)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.10 5.9
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_literal_operands_as_numbers.expected
*/
// IEEE 1800-2023 §11.10: a string literal operand is a constant number made
// of the 8-bit ASCII codes of its characters, and an operator treats the whole
// string as a single numeric value. When a vector wider than the literal
// receives it, the vector is padded on the left with zeros, as for an
// unsigned value that is not a string.
//
// "AZ" + 200 carries from the low character into the high one (16'h4222).
// "Ab" > "B" compares the numbers 16'h4162 and 8'h42, so it is 1, though "Ab"
// sorts before "B" as text; "BA" > "AB" is 1 and "AB" > "BA" is 0. The
// literal equals the number of its codes, shifts by whole bits and masks bit
// by bit like a number. A 48-bit and a 4-state 32-bit vector receive shorter
// literals and get zeros, not x, on the left, the same bits that the unsigned
// number 16'h4869 gives.

module test_string_literal_operands_as_numbers;
  bit   [15:0]    sum16, shr16;
  bit   [7:0]     masked;
  bit   [8*6:1]   wide_str, wide_num;
  logic [31:0]    lv;

  initial begin
    sum16 = "AZ" + 16'd200;
    $display("\"AZ\" + 200 = %h", sum16);
    $display("\"Ab\" > \"B\" = %b, \"BA\" > \"AB\" = %b, \"AB\" > \"BA\" = %b",
             "Ab" > "B", "BA" > "AB", "AB" > "BA");
    $display("\"ab\" == 16'h6162 = %b, \"ab\" == 16'h6261 = %b",
             "ab" == 16'h6162, "ab" == 16'h6261);
    shr16 = "AB" >> 8;
    masked = "a" & 8'hdf;
    $display("\"AB\" >> 8 = %h, \"a\" & 8'hdf = %h", shr16, masked);
    wide_str = "Hi";
    wide_num = 16'h4869;
    lv = "xyz";
    $display("wide_str=%h wide_num=%h lv=%h", wide_str, wide_num, lv);
  end
endmodule

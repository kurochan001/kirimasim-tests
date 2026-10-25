/*
:name: test_format_field_width_padding_radices
:description: an explicit field width pads a shorter decimal or string value with spaces and a shorter hexadecimal, octal or binary value with zeros, and a longer value widens the field without truncation (IEEE 1800-2023 Section 21.2.1.2)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_format_field_width_padding_radices.expected
*/
// IEEE 1800-2023 §21.2.1.2: a field width between % and the format letter
// replaces the automatic size. A value with fewer characters than the width
// is padded on the left up to the width, with spaces for decimal and string
// values and with zeros for hexadecimal, octal and binary values. A value
// with more characters than the width widens the field to hold all of it,
// and nothing is cut off.
// The first line pads 7 (8 bits), the string literal "ab", the string
// variable "hi" and the negative int -42 to wider fields in every radix; the
// second line gives values longer than a width of 2 in every radix.
// Icarus Verilog 13.0 pads %5h, %5o and %10b of the 8-bit value with spaces
// in front of its automatic size ("   07"), where the clause asks for zeros.

module test_format_field_width_padding_radices;
  logic [7:0] b8 = 8'd7;
  string str = "hi";
  int neg = -42;
  logic [31:0] big = 32'd123456;

  initial begin
    $display("[%5d][%5h][%5o][%10b][%5s][%4s][%6d]", b8, b8, b8, b8, "ab", str, neg);
    $display("[%2d][%2h][%2o][%2b][%2s][%1s]", big, 32'habcde, 32'o7654, 8'b10110, "wxyz", str);
  end
endmodule

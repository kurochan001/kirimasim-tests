/*
:name: test_format_field_width_override_and_zero
:description: A field width between % and the radix letter replaces the automatic width of %d, %h, %o and %b, both above and below it, and a width of 0 gives the minimum width with no leading spaces or zeros (IEEE 1800-2023 Section 21.2.1.2)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_format_field_width_override_and_zero.expected
*/
// IEEE 1800-2023 §21.2.1.2: without a field width a value takes the columns
// of the largest value of its type: for the 16-bit value v that is 5 columns
// in decimal (leading zeros replaced by spaces) and 4, 6 and 16 digits in
// hexadecimal, octal and binary (leading zeros shown). A field width written
// between % and the radix letter replaces that size, and a width of 0 shows
// the value in as few columns as it needs, with no leading space or zero.
// v is 291, which is 123 in hexadecimal, 443 in octal and 100100011 in
// binary, so no hexadecimal letter appears. The first line is the automatic
// size, for comparison. The second gives widths above it, and the third
// widths below it: 4 columns for %d, so one space and not two, and widths that
// fit the digits exactly. The last two lines give width 0 to v and to the
// value 7, whose automatic sizes would start with spaces or zeros.
// Icarus Verilog 13.0 pads %6h, %8o and %12b with spaces in front of the
// automatic size ("[  0123]"), where the clause asks for leading zeros.

module test_format_field_width_override_and_zero;
  logic [15:0] v = 16'd291;
  logic [15:0] s = 16'd7;

  initial begin
    $display("auto: [%d] [%h] [%o] [%b]", v, v, v, v);
    $display("wider: [%8d] [%6h] [%8o] [%12b]", v, v, v, v);
    $display("narrower: [%4d] [%3d] [%3h] [%4o] [%9b]", v, v, v, v, v);
    $display("zero: [%0d] [%0h] [%0o] [%0b]", v, v, v, v);
    $display("zero small: [%0d] [%0h] [%0o] [%0b]", s, s, s, s);
  end
endmodule

/*
:name: test_format_explicit_field_width
:description: An explicit field width on %h, %b and %d replaces the automatic width, padding a shorter result and expanding for a longer one (IEEE 1800-2023 Section 21.2.1.2)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_format_explicit_field_width.expected
*/
// IEEE 1800-2023 §21.2.1.2: a field width between % and the radix letter
// overrides the automatic sizing of the displayed value, which for a 32-bit
// value would be 8 hex digits or 32 binary digits. A result shorter than the
// field width is padded on the left, with zeros for %h and %b and spaces for
// %d; a longer one widens the field; and a width of 0 gives the minimum
// width.

module test_format_explicit_field_width;
  initial begin
    $display("[%3h] [%3h] [%1h] [%4h] [%3b] [%3d] [%0h]", 32'h5, 32'h1234, 32'h20, 32'he0,
             32'b1, 32'd5, 32'h20);
  end
endmodule

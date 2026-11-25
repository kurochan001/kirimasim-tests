/*
:name: test_string_octal_escape_outside_byte_range
:description: An octal escape at 377 is valid and a tool may reject an escape above that byte boundary
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.9.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_octal_escape_outside_byte_range.expected
*/
// The default run checks in-range bytes. tools/run_optional_lexical.py
// substitutes \400 for \376 and accepts a source-local range error or
// successful execution that still preserves the in-range control.
module test_string_octal_escape_outside_byte_range;
  localparam in_range = "L\377R";
  localparam optional_byte = "L\376R";

  initial begin
    $display("in_range=%06h", in_range);
    $display("variant=%06h", optional_byte);
  end
endmodule

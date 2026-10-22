/*
:name: test_string_format_nul_and_field_width
:description: String formatting suppresses leading zero padding of packed values and honors field width (IEEE 1800-2023 Section 21.2.1.7)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.7
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_format_nul_and_field_width.expected
*/
// IEEE 1800-2023 21.2.1.7: A packed integral string ignores leading NUL bytes;
// a wider string field pads on the left, while the zero width form adds no
// padding.

module test_string_format_nul_and_field_width;
  bit [31:0] text_value = 32'h00004142;
  string unpadded = "AB";
  initial $display("plain=[%s] width=[%5s] zero=[%0s]", unpadded, text_value, text_value);
endmodule

/*
:name: test_string_integral_truncation_and_lexical_compare
:description: String literal assignment to integral types truncates on the left and string comparison is lexical (IEEE 1800-2023 Section 11.10.1)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.10.1 11.10.2 11.10.3 6.16
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_integral_truncation_and_lexical_compare.expected
*/
// IEEE 1800-2023 6.16 fixes integral truncation and string lexical ordering.
// Sections 11.10.1 11.10.2 11.10.3 cover copy, padding and empty literals.

module test_string_integral_truncation_and_lexical_compare;
  bit [15:0] short_text;
  bit [31:0] wide_text;
  string a = "10", b = "2";
  initial begin
    short_text = "WXYZ"; wide_text = "K";
    $display("empty=%0d zero_character=%0d", 8'(""), 8'("0"));
    $display("short=%h wide=%h lexical=%0d", short_text, wide_text, a < b);
  end
endmodule

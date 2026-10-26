/*
:name: test_expr_string_literal_ops
:description: a string literal copies into a vector, concatenates, compares, and uses eight bits per character so a two-character literal needs 16 bits (IEEE 1800-2023 11.10.1)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.10.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr_string_literal_ops.expected
*/
// IEEE 1800-2023 §11.10.1: copy, concatenation and comparison apply to string
// literals, also when they are stored in vectors, and a vector that holds n
// characters should be at least 8*n bits wide to keep the complete ASCII code.
// The test copies "AB" into a 16-bit vector and "A" into an 8-bit vector,
// compares the vectors with literals, compares a concatenation of "A" and "B"
// with "AB", and prints the size of "AB". A vector of fewer than 8*n bits, or
// a comparison that ignores the stored characters, prints a different line.

module test_expr_string_literal_ops;
  logic [15:0] v;
  logic [7:0] c;
  string s;

  initial begin
    v = "AB";
    c = "A";
    s = "AB";
    $display("v=%h c=%h", v, c);
    $display("eq=%0d neq=%0d", v == "AB", v == "AC");
    $display("cat=%0d", {"A", "B"} == "AB");
    $display("s=%0d", s == "AB");
    $display("bits=%0d", $bits("AB"));
    $finish;
  end
endmodule

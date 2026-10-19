/*
:name: test_cast_string_literal_to_narrower_type
:description: Casting a string literal to a narrower integral type keeps its rightmost characters (IEEE 1800-2023 Section 6.24.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1 5.9
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_string_literal_to_narrower_type.expected
*/
// IEEE 1800-2023 §5.9: a string literal is an integral value of 8 bits per
// character, the last character in the least significant byte. §6.24.1: a
// cast to a narrower integral type keeps the least significant bits, so
// byte'("AB") is "B" (66), shortint'("ABC") is "BC" (16'h4243) and a size
// cast 4'("AB") is the low 4 bits of "B", 2.

module test_cast_string_literal_to_narrower_type;
  byte b;
  shortint s;
  logic [3:0] n;

  initial begin
    b = byte'("AB");
    s = shortint'("ABC");
    n = 4'("AB");
    $display("byte'(\"AB\") = %0d (%s)", b, b);
    $display("shortint'(\"ABC\") = %h (%s)", s, s);
    $display("4'(\"AB\") = %0d", n);
  end
endmodule

/*
:name: test_string_literal_and_integral_conversions
:description: A string can be declared with a literal, the empty string or a string expression; converting a literal or a cast integral value to a string removes every NUL character, gives the empty string when nothing else is left, pads a partial byte with zeros on the left, and resizes the string (IEEE 1800-2023 Section 6.16)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16 6.24.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_literal_and_integral_conversions.expected
*/
// IEEE 1800-2023 §6.16: a string declaration can initialize the variable with
// a string literal, with "" or with an expression of string type; without an
// initializer the string is empty. When a literal becomes a string, its "\0"
// characters are removed, and if nothing is left the string is empty. A cast
// of an integral value to string (6.24.1) first extends the value with zeros
// on the left to a multiple of 8 bits, takes each 8 bits as a character from
// the left, and then removes the zero characters in the same way; the string
// grows or shrinks to the length of the result.
// The 20-bit value 20'h64243 becomes 24'h064243, the characters 06 42 43;
// 24'h410042 loses its middle zero byte; 16'h0000 leaves nothing. The string
// s is first 15 characters long and then shrinks to 2 and grows to 4.

module test_string_literal_and_integral_conversions;
  parameter string P = "par";
  string d_lit = "lit";
  string d_empty = "";
  string d_param = P;
  string d_expr = {P, "+"};
  string d_none;
  string s_nul = "ab\0cd";
  string s_all_nul = "\0\0\0";
  string s;
  bit [15:0] v16 = 16'h4142;
  bit [31:0] v32 = 32'h41424344;
  bit [19:0] v20 = 20'h64243;
  bit [23:0] mid = 24'h410042;
  bit [15:0] zero16 = 16'h0000;

  initial begin
    $display("declared: \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" lens %0d %0d %0d %0d %0d", d_lit,
             d_empty, d_param, d_expr, d_none, d_lit.len(), d_empty.len(), d_param.len(),
             d_expr.len(), d_none.len());
    $display("literal with NUL: \"%s\" len=%0d", s_nul, s_nul.len());
    $display("literal of NULs: \"%s\" len=%0d", s_all_nul, s_all_nul.len());
    s = "a longer string";
    $display("before cast: len=%0d", s.len());
    s = string'(v16);
    $display("16 bits: \"%s\" len=%0d", s, s.len());
    s = string'(v32);
    $display("32 bits: \"%s\" len=%0d", s, s.len());
    s = string'(v20);
    $display("20 bits: len=%0d chars %h %h %h", s.len(), s[0], s[1], s[2]);
    s = string'(mid);
    $display("zero byte inside: \"%s\" len=%0d", s, s.len());
    s = string'(zero16);
    $display("all zero: \"%s\" len=%0d", s, s.len());
  end
endmodule

/*
:name: test_macro_triple_quoted_string_newline
:description: A newline inside a triple-quoted string literal in the text of a macro does not end the macro definition, so the string keeps the newline and the text after it (IEEE 1800-2023 Section 22.5.1)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1 5.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_macro_triple_quoted_string_newline.expected
*/
// IEEE 1800-2023 §22.5.1: a newline that is not preceded by a backslash ends
// the macro text, except inside a triple-quoted string literal or a block
// comment. So TS is the string "one", a newline and "two" (5.9), and the macro
// ends after the closing triple quote; TS2 has two newlines in its string and
// ":" after it. Newlines are printed as <nl>. Icarus Verilog 13.0 does not
// accept triple-quoted string literals.

`define TS """one
two"""
`define TS2 {"""a
b
c""", ":"}

module test_macro_triple_quoted_string_newline;
  string s;

  function automatic string shown(string t);
    string r = "";
    for (int i = 0; i < t.len(); i++) r = {r, t[i] == "\n" ? "<nl>" : string'(t[i])};
    return r;
  endfunction

  initial begin
    s = `TS;
    $display("TS: [%s] len=%0d", shown(s), s.len());
    s = `TS2;
    $display("TS2: [%s] len=%0d", shown(s), s.len());
  end
endmodule

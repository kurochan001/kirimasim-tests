/*
:name: test_macro_grave_triple_quote_inner_quotes
:description: `""" turns an actual argument that holds quotation marks or a string literal into a triple-quoted string literal; `\`" inside it gives the escape sequence \" with arguments substituted around it, and an ordinary " inside it still starts a string literal in which no argument is substituted (IEEE 1800-2023 Sections 22.5.1, 5.9)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1 5.9 5.9.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_macro_grave_triple_quote_inner_quotes.expected
*/
// IEEE 1800-2023 §22.5.1: a `""" in macro text stands for a triple quotation
// mark in the expansion, and the actual arguments between two of them are
// substituted, as with `". The result is a triple-quoted string literal,
// which may hold a " character without an escape (§5.9), so an actual
// argument with quotation marks in it can be turned into a string this way,
// which `" cannot do.
// - SHOW(f("hi",2)) expands to """[f("hi",2)]""": the comma is inside
//   parentheses, so the use has one actual argument, and the string is
//   [f("hi",2)], 11 characters.
// - In ESC, each `\`" becomes the escape sequence \" (§22.5.1), which the
//   literal turns into a " (§5.9.1); both uses of v are substituted, so
//   ESC(Ann) is """Ann said \"Ann\"""" and the string is Ann said "Ann".
//   The last \" is an escape sequence, so the three quotation marks after it
//   end the literal.
// - In PLAIN, the ordinary " starts a string literal of the macro text that
//   ends at the next " (§22.5.1: a " always starts a string literal), and no
//   argument is substituted inside a string literal, so PLAIN(Ann) is
//   """Ann said "v".""" and the string keeps the letter v: Ann said "v".
//   A character (the period) separates that " from the closing `""",
//   because four quotation marks in a row would end the literal after the
//   third.
// The 5.052 release of Verilator prints the expected output; Icarus Verilog
// 13.0 does not support `""" and reports syntax errors on its uses.

`define SHOW(e) `"""[e]`"""
`define ESC(v) `"""v said `\`"v`\`"`"""
`define PLAIN(v) `"""v said "v".`"""

module test_macro_grave_triple_quote_inner_quotes;
  string s;

  initial begin
    s = `SHOW(f("hi",2));
    $display("SHOW: %s len=%0d", s, s.len());
    s = `ESC(Ann);
    $display("ESC: %s len=%0d", s, s.len());
    s = `PLAIN(Ann);
    $display("PLAIN: %s len=%0d", s, s.len());
  end
endmodule

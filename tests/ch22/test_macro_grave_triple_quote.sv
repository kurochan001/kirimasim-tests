/*
:name: test_macro_grave_triple_quote
:description: `""" in macro text makes a triple quotation mark in the expansion with the actual arguments substituted; a backslash and newline inside it leave the newline in the expansion and drop the backslash, and a newline without a backslash ends the macro definition; an ordinary """ in mixed text starts a triple-quoted string literal whose characters stay as they are (IEEE 1800-2023 Section 22.5.1)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1 5.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_macro_grave_triple_quote.expected
*/
// IEEE 1800-2023 §22.5.1: like `", a `""" stands for a triple quotation mark
// in the expansion, with actual arguments substituted and embedded macros
// expanded. Unlike in a triple-quoted string literal, a newline inside it ends
// the macro definition; a backslash and newline inside it leave the newline in
// the expansion, without the backslash. So TQ(X) is the triple-quoted string
// "first X", a newline and "second bob", with `WHO expanded (5.9). TQ_OPEN
// holds a `""" followed by a plain newline: the newline ends that macro, which
// is never used, and the next line, the definition of AFTER_OPEN, is read as a
// directive of its own. A """ in the text always starts a triple-quoted string
// literal that ends at the next """, and what is inside, grave accents
// included, stays as it is: in TTAIL the """ of `""" ends the literal
// """x`""", and in MIXT the second literal is """-`x-""". Newlines are printed
// as <nl>. Icarus Verilog 13.0 does not accept `"""; the 5.052 release
// of Verilator does not end TQ_OPEN at the newline ("EOF in unterminated
// string"), and without TQ_OPEN it replaces the backslash and newline in TQ by
// a space.

`define WHO bob
`define TQ(v) `"""first v\
second `WHO`"""
`define TQ_OPEN `"""x
`define AFTER_OPEN 5
`define TTAIL(x) """x`"""
`define MIXT(x) {`"""x`""", """-`x-"""}

module test_macro_grave_triple_quote;
  string s;

  function automatic string shown(string t);
    string r = "";
    for (int i = 0; i < t.len(); i++) r = {r, t[i] == "\n" ? "<nl>" : string'(t[i])};
    return r;
  endfunction

  initial begin
    s = `TQ(X);
    $display("TQ(X): [%s] len=%0d", shown(s), s.len());
    $display("AFTER_OPEN: %0d", `AFTER_OPEN);
    s = `TTAIL(1);
    $display("TTAIL(1): [%s]", s);
    s = `MIXT(7);
    $display("MIXT(7): [%s]", s);
  end
endmodule

/*
:name: test_macro_grave_triple_quote_expansion_steps
:description: inside `""" a third backslash before the newline continues the macro and keeps the newline while \\ stays an escaped backslash of the literal, argument defaults are substituted, an embedded macro with arguments is expanded after the outer substitution, and `` joins an argument to the text that follows (IEEE 1800-2023 Sections 22.5.1, 5.9.1)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1 5.9 5.9.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_macro_grave_triple_quote_expansion_steps.expected
*/
// IEEE 1800-2023 §22.5.1: the text between two `""" becomes a triple-quoted
// string literal in the expansion, with actual arguments substituted and
// embedded macros expanded.
// - BS follows the MACRO4 example of §22.5.1: of the three backslashes at the
//   end of its first line, only the last one, with the newline, is the
//   continuation; inside `""" that backslash is dropped and the newline kept.
//   The first two stay in the expansion and form the escape sequence \\ of
//   the literal, one backslash (§5.9.1). So BS(path) is the string path, a
//   backslash, a newline and end: 9 characters, printed with the newline as
//   <nl>.
// - DFLT has defaults for both formal arguments; an omitted or empty actual
//   argument takes the default (§22.5.1), here none and the string literal
//   "x y", whose quotation marks stay in the triple-quoted literal.
//   DFLT() is <none|"x y">, DFLT(,5) is <none|5>, DFLT(k) is <k|"x y">.
// - In NEST the use of ADD is expanded after x is substituted, so NEST(7)
//   holds the text 7+2, not a sum.
// - In PASTE, `` joins the argument and _q without white space, so the
//   identifier-like text abc_q is formed before the literal is made.
// The characters next to each `""" are not quotation marks, because a " just
// before the closing triple quotation mark would end the literal one
// character early.
// The 5.052 release of Verilator puts a space in place of the backslash and
// newline of BS (the other lines match); Icarus Verilog 13.0 does not support
// `""" and reports syntax errors on its uses.

`define BS(v) `"""v\\\
end`"""
`define DFLT(a=none, b="x y") `"""<a|b>`"""
`define ADD(a, b) a+b
`define NEST(x) `"""sum=`ADD(x,2)`"""
`define PASTE(p) `"""p``_q`"""

module test_macro_grave_triple_quote_expansion_steps;
  string s;

  function automatic string shown(string t);
    string r = "";
    for (int i = 0; i < t.len(); i++) r = {r, t[i] == "\n" ? "<nl>" : string'(t[i])};
    return r;
  endfunction

  initial begin
    s = `BS(path);
    $display("BS: [%s] len=%0d", shown(s), s.len());
    s = `DFLT();
    $display("DFLT(): %s", s);
    s = `DFLT(,5);
    $display("DFLT(,5): %s", s);
    s = `DFLT(k);
    $display("DFLT(k): %s", s);
    s = `NEST(7);
    $display("NEST(7): %s", s);
    s = `PASTE(abc);
    $display("PASTE(abc): %s", s);
  end
endmodule

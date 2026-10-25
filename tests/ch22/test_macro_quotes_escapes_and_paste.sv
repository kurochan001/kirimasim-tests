/*
:name: test_macro_quotes_escapes_and_paste
:description: In macro text, `" makes a quotation mark inside which actual arguments and other macros are substituted, `\`" makes the escape sequence \", `` joins tokens into one identifier, an ordinary string literal is copied unchanged with its formal names and grave accents, and " always starts a string literal, also before `" (IEEE 1800-2023 Section 22.5.1)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_macro_quotes_escapes_and_paste.expected
*/
// IEEE 1800-2023 §22.5.1: no macro or argument substitution happens inside a
// string literal, so PLAIN keeps "x meets `WHO". A `" stands for a quotation
// mark in the expansion, with the actual arguments substituted and embedded
// macros expanded, so Q(alice) is "alice meets bob". A `\`" gives \", so ESC
// builds a string with quotation marks in it. `` delimits tokens without
// adding white space, so PASTE(foo, bar) is the identifier foo_bar. In mixed
// text a " always starts a string literal that runs to the next ", and what is
// inside, grave accents included, stays as it is: in TAIL the " of `"
// terminates the literal "x`", and in MIX the second literal is "-`x-". Icarus
// Verilog 13.0 substitutes the actual argument for x inside the ordinary
// string literals of PLAIN, TAIL and MIX.

`define WHO bob
`define Q(x) `"x meets `WHO`"
`define PLAIN(x) "x meets `WHO"
`define ESC(x) `"say `\`"x`\`" now`"
`define PASTE(a, b) a``_``b
`define TAIL(x) "x`"
`define MIX(x) {`"x`", "-`x-"}

module test_macro_quotes_escapes_and_paste;
  int foo_bar = 42;
  int left_right = 7;
  string s;

  initial begin
    $display("`\": %s", `Q(alice));
    $display("string literal: %s", `PLAIN(alice));
    $display("`\\`\": %s", `ESC(hi));
    $display("``: %0d %0d", `PASTE(foo, bar), `PASTE(left, right));
    $display("\" before `\": %s", `TAIL(1));
    s = `MIX(7);
    $display("mixed: %s", s);
  end
endmodule

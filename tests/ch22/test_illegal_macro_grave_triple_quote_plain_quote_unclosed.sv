/*
:name: test_illegal_macro_grave_triple_quote_plain_quote_unclosed
:description: an ordinary " inside a `""" of macro text still starts a quoted string literal, which has to be closed on its line, so a lone " there is an error although the expansion would be a triple-quoted literal that allows one (IEEE 1800-2023 Sections 22.5.1, 5.9)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.5.1 5.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the macro text of LONE has a " after `""" with no closing " before the end of its line, so its quoted string literal is not terminated
:expected_stderr_regex: test_illegal_macro_grave_triple_quote_plain_quote_unclosed\.sv:36:
*/
// IEEE 1800-2023 §22.5.1: `""" and """ may be mixed in macro text, but a "
// or """ written there always starts a string literal, which shall have its
// closing delimiter; the macro text also shall not be split across a string
// literal. A quoted string literal ends on its line unless the newline is
// escaped (§5.9). That holds after a `""" as well, although the
// expansion becomes a triple-quoted literal, in which a lone " would be
// allowed (§5.9).
// PAIR has a closed literal "v" between its `""": the legal design prints
// PAIR(Ann), Ann said "v". (no argument is substituted inside the literal).
// LONE has a single " that is not closed before the newline that ends its
// text, so its definition is illegal although the design never uses it.
// LONE has no closing `""" either; a newline ends the text of a `""" (which
// test_macro_grave_triple_quote relies on), so the only error is the open
// quoted literal. No grave accent or quotation mark follows that ", not even
// in the comment, because either would close the literal. A tool that treats
// the text after `""" as plain characters accepts the design.
// The 5.052 release of Verilator keeps reading the text of LONE across the
// newline and reports an unterminated triple-quoted string at the end of
// the file instead. Icarus Verilog 13.0 does not support `""" and reports a
// syntax error on the use of PAIR.

`define PAIR(v) `"""v said "v".`"""
`define LONE(v) `"""v said "v   // illegal: the quotation mark before v is never closed

module test_illegal_macro_grave_triple_quote_plain_quote_unclosed;
  string s;

  initial begin
    s = `PAIR(Ann);
    $display("%s", s);
  end
endmodule

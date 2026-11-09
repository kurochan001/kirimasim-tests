/*
:name: test_illegal_macro_grave_triple_quote_newline_ends_text
:description: a newline without a backslash inside a `""" ends the macro text, unlike a newline inside a triple-quoted string literal, so the line after it is ordinary source text, and a `""" left there is an error (IEEE 1800-2023 Section 22.5.1)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the definition of TWO ends at the first newline inside its `""", so the next line, with a grave accent and triple quotation mark, is source text outside any macro
:expected_stderr_regex: test_illegal_macro_grave_triple_quote_newline_ends_text\.sv:35:
*/
// IEEE 1800-2023 §22.5.1: a newline inside the expansion of a `""" ends the
// macro definition, unlike a newline inside a triple-quoted string literal;
// only a backslash before the newline continues the text, and then the
// newline is kept and the backslash dropped. TWO_OK has that backslash, and
// the legal design prints its string, "first a", a newline and "second a",
// with the newline shown as <nl>. TWO has none, so its text ends after
// "first v", and the next line is read as source text: the identifiers
// second and v followed by a grave accent and a triple quotation mark, which
// are neither a directive nor a macro use. A tool that keeps reading the text
// of TWO across the newline accepts the design. The error is the line after
// the definition of TWO.
// The 5.052 release of Verilator accepts the design and prints the string
// of TWO_OK with a space for the newline. Icarus Verilog 13.0 does not
// support `""" (it rejects the uses in the legal tests of this feature); it
// reports a syntax error on the marked line as well, which cannot be told
// apart from that missing support.

`define TWO_OK(v) `"""first v\
second v`"""

`define TWO(v) `"""first v
second v`"""   // illegal: the definition of TWO ended on the line above

module test_illegal_macro_grave_triple_quote_newline_ends_text;
  string s;

  function automatic string shown(string t);
    string r = "";
    for (int i = 0; i < t.len(); i++) r = {r, t[i] == "\n" ? "<nl>" : string'(t[i])};
    return r;
  endfunction

  initial begin
    s = `TWO_OK(a);
    $display("%s", shown(s));
  end
endmodule

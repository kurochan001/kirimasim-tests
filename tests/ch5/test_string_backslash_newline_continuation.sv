/*
:name: test_string_backslash_newline_continuation
:description: A backslash before a newline continues a string literal, a double backslash before a newline is one backslash character, and a triple-quoted string still decodes the \" and \n escapes (IEEE 1800-2023 Section 5.9.1)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.9.1 5.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_backslash_newline_continuation.expected
*/
// IEEE 1800-2023 §5.9: in a string literal, a backslash right before a
// newline continues the literal on the next line, and the backslash and the
// newline are dropped. A triple-quoted string can hold a newline and a double
// quote as they are, and an escaped newline in it is treated as in a quoted
// string. §5.9.1: a double backslash right before a newline is the escape of
// one backslash, not the start of a continuation, so a continuation after a
// kept backslash needs a third backslash; the escapes \" and \n also work in
// a triple-quoted string.
// The literals are:
//   one  "ab", backslash, newline, "cd": continued, so abcd
//   two  "ab", three backslashes, newline, "cd": a backslash, then continued
//   tri  triple-quoted "ab", two backslashes, newline, "cd": a backslash and
//        the newline itself are kept
//   cont triple-quoted "ab", backslash, newline, "cd": continued
//   esc  triple-quoted q \" r \n s " t, newline, u: the escaped and the raw
//        quote and newline give the same codes 34 and 10
// Each line prints the length and the character codes of one literal.
// Icarus Verilog 13.0 does not support triple-quoted string literals.

module test_string_backslash_newline_continuation;
  task automatic show(string name, string v);
    string line;
    line = $sformatf("%s len=%0d:", name, v.len());
    for (int i = 0; i < v.len(); i++) line = {line, $sformatf(" %0d", v[i])};
    $display("%s", line);
  endtask

  initial begin
    show("one", "ab\
cd");
    show("two", "ab\\\
cd");
    show("tri", """ab\\
cd""");
    show("cont", """ab\
cd""");
    show("esc", """q\"r\ns"t
u""");
  end
endmodule

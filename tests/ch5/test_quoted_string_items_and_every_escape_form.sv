/*
:name: test_quoted_string_items_and_every_escape_form
:description: A quoted string holds printable characters other than backslash and double quote directly, and every form of escape sequence: a backslash before a character of Table 5-1, before another character, before a newline, before one to three octal digits and before x with one or two hex digits (IEEE 1800-2023 Section 5.9)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.9 5.9.1 A.8.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_quoted_string_items_and_every_escape_form.expected
*/
// IEEE 1800-2023 §5.9 and A.8.8: a quoted string is a double quote, any
// number of items and escape sequences, and a double quote. An item is any
// ASCII character except a backslash, a newline and a double quote; an escape
// sequence is a backslash followed by a character, by one to three octal
// digits, or by x and one or two hex digits. §5.9.1, Table 5-1: \n \t \\ \"
// \v \f \a stand for newline (10), tab (9), backslash (92), double quote (34),
// vertical tab (11), form feed (12) and bell (7); \ddd and \xdd give the
// character of that code; a backslash before a character that is not in the
// table stands for that character, so \q is q. §5.9: a backslash before a
// newline is dropped together with the newline. Each escape sequence is one
// 8-bit character.
//
// The string s mixes plain characters (a single quote, a space, $, / and *)
// with each kind of escape: \7 and \12 are followed by characters that are
// not octal digits, and \x9 by one that is not a hex digit. The test prints
// the character codes of s and its length, the string c that continues over
// a backslash and a newline, and the width of a literal with an escaped
// double quote, 4 characters or 32 bits.
//
// The 5.052 release of Verilator rejects \q as an unknown escape sequence;
// §5.9.1 treats it as the letter q.

module test_quoted_string_items_and_every_escape_form;
  string s, c;

  initial begin
    s = "a\qb\7c\12d\101e\x9g\x41h\"\\\v\f\a\t\n' $/*";
    c = "line\
cont";
    for (int i = 0; i < s.len(); i++) $write("%0d ", s[i]);
    $display("len=%0d", s.len());
    $display("c=%s len=%0d", c, c.len());
    $display("bits=%0d", $bits("ab\"c"));
  end
endmodule

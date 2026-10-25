/*
:name: test_display_backslash_escapes
:description: backslash escape sequences in the string literal of a display task produce the characters of Table 5-1 (IEEE 1800-2023 Section 21.2.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1 5.9.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_display_backslash_escapes.expected
*/
// IEEE 1800-2023 §21.2.1: in a string literal given to $display, a backslash
// means that the next characters are an escape sequence of Table 5-1
// (§5.9.1): \t is a tab, \\ a backslash, \" a double quote, \n a newline,
// \v a vertical tab, \f a form feed, \a a bell, \ddd the character with the
// octal code of one to three digits and \xdd the character with the
// hexadecimal code of one or two digits. A backslash before a character that
// is not in the table stands for that character alone (§5.9.1).
// Printable results and tabs (including the one-digit \x9) are shown as they
// are. The vertical tab, form feed and bell, and the one-digit escapes \7
// and \x5, which give other control characters, are written with $swrite
// into a string whose character codes are then printed.
// Release 5.052 of Verilator rejects the one-digit escape \x9 as unknown.

module test_display_backslash_escapes;
  string s;

  initial begin
    $display("[a\tb]");
    $display("[\\][\"]");
    $display("<first\nsecond>");
    $display("[\101\102\103][\60x]");
    $display("[\x41\x7a][\x9|]");
    $display("[\q\w]");
    $swrite(s, "\v\f\a\7\x5");
    $display("%0d %0d %0d %0d %0d len=%0d", s[0], s[1], s[2], s[3], s[4], s.len());
  end
endmodule

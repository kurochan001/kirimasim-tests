/*
:name: test_string_escape_character_codes
:description: Each escape sequence of Table 5-1 gives one character with its fixed code, octal and hexadecimal escapes take at most three and two digits, and an escape of another character keeps only that character (IEEE 1800-2023 Section 5.9.1)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.9.1 5.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_escape_character_codes.expected
*/
// IEEE 1800-2023 §5.9.1, Table 5-1: \n, \t, \\, \", \v, \f and \a each stand
// for one character: newline (10), tab (9), backslash (92), double quote
// (34), vertical tab (11), form feed (12) and bell (7). \ddd takes one to
// three octal digits, and a shorter one is only legal when the next
// character is not an octal digit; \xdd takes one or two hexadecimal digits
// in the same way. A backslash before a character that is not in the table
// is dropped and the character is kept, so \b, \q and \r are the letters
// b, q and r, not C control characters. §5.9: each escape is one 8-bit
// character of the literal.
// The test passes each literal to a string argument and prints its length
// and the code of every character, so a wrong code, a merged or split
// character, or a dropped character changes the line.
// The release 5.052 of Verilator rejects a hexadecimal escape with one digit
// (\x4 before g, \x7 before -), which §5.9.1 allows.

module test_string_escape_character_codes;
  task automatic show(string name, string v);
    string line;
    line = $sformatf("%s len=%0d:", name, v.len());
    for (int i = 0; i < v.len(); i++) line = {line, $sformatf(" %0d", v[i])};
    $display("%s", line);
  endtask

  initial begin
    show("table", "\n\t\\\"\v\f\a");
    // three digits, then the digit 2; two digits before g; one before q
    show("octal", "\101\1012\61g\7q");
    // two digits, then the digit 4; one digit before g; one before -
    show("hex", "\x41\x414\x4g\x7-");
    show("other", "\b\q\r");
  end
endmodule

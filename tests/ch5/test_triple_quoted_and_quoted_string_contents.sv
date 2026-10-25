/*
:name: test_triple_quoted_and_quoted_string_contents
:description: A string literal is a quoted or a triple-quoted string; the triple-quoted one holds newlines and double quotes, also two in a row, as plain characters, while a backslash still starts the same escape sequences as in a quoted string (IEEE 1800-2023 Section 5.9)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.9 5.9.1 A.8.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_triple_quoted_and_quoted_string_contents.expected
*/
// IEEE 1800-2023 §5.9 and A.8.8: a string literal is a quoted string or a
// triple-quoted string, three double quotes, any number of items and escape
// sequences, and three double quotes. An item of a triple-quoted string is
// any ASCII character except a backslash, so a newline and a double quote,
// or two of them in a row, are part of the string; three in a row end it.
// The escape sequences are the same as in a quoted string (§5.9.1): \\ \"
// \n \t, \ddd in octal and \xdd in hex, and a backslash before a newline,
// which drops both.
//
// q is a quoted string with \t (code 9). t1 is a triple-quoted string of 30
// characters: the 20 characters of the first line with its double quotes,
// the newline that ends it (code 10), then next, A from \x41, B from \102, a
// backslash from \\ (92), a double quote from \" (34) and a newline from \n
// (10). t2 continues over an escaped newline. The test prints t1, then the
// lengths and the codes of the special characters.
//
// Icarus Verilog 13.0 does not support triple-quoted strings of IEEE
// 1800-2023.

module test_triple_quoted_and_quoted_string_contents;
  string q, t1, t2;

  initial begin
    q = "x\ty";
    t1 = """say "hi" and ""bye""
next\x41\102\\\"\n""";
    t2 = """con\
tinued""";
    $display("q=%0d %0d", q.len(), q[1]);
    $display("%s", t1);
    $display("t1=%0d %0d %0d %0d %0d", t1.len(), t1[20], t1[27], t1[28], t1[29]);
    $display("t2=%s %0d", t2, t2.len());
  end
endmodule

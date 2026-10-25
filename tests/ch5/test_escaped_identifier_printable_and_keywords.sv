/*
:name: test_escaped_identifier_printable_and_keywords
:description: An escaped identifier can hold every printable ASCII character, its backslash and terminating white space are not part of the name so it is the same as the simple spelling, and an escaped keyword is an ordinary identifier (IEEE 1800-2023 Section 5.6.1)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.6.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_escaped_identifier_printable_and_keywords.expected
*/
// IEEE 1800-2023 §5.6.1: an escaped identifier starts with a backslash and
// ends with white space, and can hold any printable ASCII character, codes 33
// to 126. The backslash and the white space are not part of the name, so
// \cnt and cnt are the same identifier. An escaped keyword is a user-defined
// identifier.
// Two escaped names hold the characters 33 to 79 and 80 to 126 in order, so
// together they use every printable character, including quotes, the grave
// accent, the backslash, brackets, braces, commas and semicolons. Each is
// declared, written and read. The variable cnt is declared with the escaped
// spelling and used with the simple one, total the other way, and the
// instance \u1 is reached as u1 in a hierarchical name. The keywords begin,
// end, module and int are used as names in escaped form.
// Icarus Verilog 13.0 reads the grave accent inside the second name as the
// start of a macro use, which §5.6.1 does not allow.

module escaped_identifier_child;
  int val = 31;
endmodule

module test_escaped_identifier_printable_and_keywords;
  int \!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNO ;
  int \PQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~ ;
  int \cnt = 5;
  int total;
  int \begin = 1, \end = 2, \module = 3, \int = 4;

  escaped_identifier_child \u1 ();

  initial begin
    \!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNO = 47;
    \PQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~ =
      \!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNO + 1;
    $display("printable: %0d %0d",
             \!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNO ,
             \PQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~ );
    \total = cnt + 10;
    cnt = cnt + 1;
    $display("same name: cnt=%0d total=%0d child=%0d", \cnt , total, u1.val);
    $display("keywords: %0d %0d %0d %0d", \begin , \end , \module , \int );
  end
endmodule

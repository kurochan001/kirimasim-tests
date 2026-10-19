/*
:name: test_escaped_identifier_comment_chars
:description: Escaped identifiers that contain the characters of comment delimiters are names, not comments, also next to operators (IEEE 1800-2023 Section 5.6.1)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.6.1 11.4.1 11.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_escaped_identifier_comment_chars.expected
*/
// IEEE 1800-2023 §5.6.1: an escaped identifier starts with a backslash and ends
// at the next white space, and every printable character in between is part of
// the name. So \a//b and \c/*d*/e are names, not the start of comments, also
// when they are operands of an operator or the target of an assignment
// operator (11.4.1) or of ++ (11.4.2).

module test_escaped_identifier_comment_chars;
  int \a//b , \c/*d*/e , \k//m , \p+q , plain_v, x, y, z, w;
  int errors = 0;

  task automatic check(string what, int got, int exp);
    if (got !== exp) begin
      $display("WRONG %s = %0d, expected %0d", what, got, exp);
      errors++;
    end
  endtask

  initial begin
    \a//b = 5;
    \c/*d*/e = 12;
    \p+q = 5;
    \k//m = 7;
    plain_v = 5;
    \a//b += 3;
    check("A \\a//b += 3", \a//b , 8);
    \c/*d*/e >>= 2;
    check("B \\c/*d*/e >>= 2", \c/*d*/e , 3);
    y = \a//b + 1;
    check("C y = \\a//b + 1", y, 9);
    z = 2 + \c/*d*/e ;
    check("D z = 2 + \\c/*d*/e", z, 5);
    \a//b = \a//b * 2;
    check("E \\a//b = \\a//b * 2", \a//b , 16);
    // Controls: an escaped name without comment characters, a plain name, a
    // plain read, ++, and an assignment followed by a real comment.
    \p+q += 3;
    check("ctl \\p+q += 3", \p+q , 8);
    plain_v += 3;
    check("ctl plain_v += 3", plain_v, 8);
    x = \k//m ;
    check("ctl x = \\k//m", x, 7);
    \k//m ++;
    check("ctl \\k//m ++", \k//m , 8);
    w = plain_v + 1;  // a real comment after the statement
    check("ctl w = plain_v + 1 with a trailing comment", w, 9);
    if (errors == 0) begin
      $display("TEST PASSED: escaped names holding comment characters");
    end else begin
      $display("TEST FAILED: %0d errors", errors);
    end
    $finish;
  end
endmodule

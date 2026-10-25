/*
:name: test_identifier_simple_escaped_and_system_name_forms
:description: Simple identifiers of one character, starting with a letter or an underscore and holding digits, underscores and dollar signs are case sensitive; escaped identifiers hold any printable characters up to the white space (blank, tab or newline) that ends them and name the same object as the simple identifier with the same characters; system function names hold letters, digits, underscores and dollar signs (IEEE 1800-2023 Section 5.6)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.6 5.6.1 5.6.3 A.9.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_identifier_simple_escaped_and_system_name_forms.expected
*/
// IEEE 1800-2023 §5.6 and A.9.3: an identifier is a simple identifier or an
// escaped identifier. A simple identifier is a letter or underscore followed
// by any number of letters, digits, underscores and dollar signs, so q, _ and
// _9$z are identifiers, and identifiers are case sensitive: abc and ABC are
// two variables. §5.6.1: an escaped identifier is a backslash, printable
// characters other than white space, and the white space that ends it.
// Neither the backslash nor the white space belongs to the name, so \cpu3 and
// cpu3 are one variable, and an escaped keyword such as \net is a user name.
// The comma in \p,q is part of that one name, so the declaration declares a
// single variable. The escaped names in the sums below end with a blank, a
// tab and a newline. §5.6.3 and A.9.3: a system task or function name is $
// followed by letters, digits, underscores and dollar signs; the test calls
// $clog2, $test$plusargs and $urandom_range with arguments that fix their
// results (4, 0 for an argument that is not given, and 3). A system name is
// not escaped: \$clog2 is a user variable, here 50, next to $clog2.

module test_identifier_simple_escaped_and_system_name_forms;
  int q = 1, _ = 2, _9$z = 3, a$b$ = 4;
  int abc = 5, ABC = 6;
  int \cpu3 = 7;
  int \a+b = 8;
  int \{x,y} = 9;
  int \net = 10;
  int \p,q = 11;
  int \$clog2 = 50;
  int s1, s2, s3;

  initial begin
    s1 = \a+b + \{x,y} + 100;
    s2 = \net	+ 200;
    s3 = \p,q
         + 300;
    $display("simple %0d %0d %0d %0d %0d %0d", q, _, _9$z, a$b$, abc, ABC);
    $display("escaped %0d %0d %0d %0d %0d %0d", cpu3, \cpu3 , \a+b , \{x,y} , \net , \p,q );
    $display("sums %0d %0d %0d", s1, s2, s3);
    $display("system %0d %0d %0d %0d", $clog2(9), $test$plusargs("a04_no_such_arg"),
             $urandom_range(3, 3), \$clog2 );
  end
endmodule

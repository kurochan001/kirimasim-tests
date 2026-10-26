/*
:name: test_illegal_randsequence_missing_return
:description: A return statement in a production that returns a value shall specify an expression of the correct type, so return without an expression in the int production val is an error (IEEE 1800-2023 Section 18.17.7)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.17.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the int production val uses return without an expression
:expected_stderr_regex: test_illegal_randsequence_missing_return\.sv:24:
*/
// IEEE 1800-2023 §18.17.7: a production that returns data declares a type
// before its name, and a return statement in it shall specify an expression
// of the correct type, just like a nonvoid function. The production val is
// declared with the return type int, and main generates it, so the return
// must give an int. The return in val has no expression and is illegal.

module test_illegal_randsequence_missing_return;
  initial begin
    randsequence(main)
      main : val;
      int val : { return; };   // illegal: no return expression
    endsequence
  end
endmodule

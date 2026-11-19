/*
:name: test_illegal_mailbox_param_peek_string_from_int
:description: peek on a mailbox parameterized with int cannot take a string variable, a type mismatch that the compiler reports (IEEE 1800-2023 Section 15.4.9)
:tags: ch15
:type: elaboration
:lrm: 1800-2023 15.4.9
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: peek of a mailbox of ints is given the string variable s, whose type is not equivalent to int
:expected_stderr_regex: test_illegal_mailbox_param_peek_string_from_int\.sv:35:
*/
// IEEE 1800-2023 §15.4.9: for a mailbox parameterized with a type, the
// compiler checks that the arguments of put, try_put, peek, try_peek, get and
// try_get have types equivalent to that type, so that a mismatch is found at
// compile time instead of at run time.
// Here the mailbox holds ints: peek into the int variable n is legal, peek
// into the string variable s is not.
// This is one of six tests, one for each of these methods; the others are
// the tests test_illegal_mailbox_param_* of this directory for the other
// five methods.
// Icarus Verilog 13.0 does not support a parameterized mailbox; its syntax
// error on the declaration does not count.

module test_illegal_mailbox_param_peek_string_from_int;
  mailbox #(int) box = new();
  string s = "word";
  int n = 5;
  int r;

  initial begin
    box.put(1);
    box.peek(n);
    box.peek(s);   // illegal
  end
endmodule

/*
:name: test_illegal_mailbox_param_put_int_into_string
:description: put on a mailbox parameterized with string cannot take an int variable, a type mismatch that the compiler reports (IEEE 1800-2023 Section 15.4.9)
:tags: ch15
:type: elaboration
:lrm: 1800-2023 15.4.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: put of a mailbox of strings is given the int variable n, whose type is not equivalent to string
:expected_stderr_regex: test_illegal_mailbox_param_put_int_into_string\.sv:37:
*/
// IEEE 1800-2023 §15.4.9: for a mailbox parameterized with a type, the
// compiler checks that the arguments of put, try_put, peek, try_peek, get and
// try_get have types equivalent to that type, so that a mismatch is found at
// compile time instead of at run time.
// Here the mailbox holds strings: put with a string literal and with the
// string variable s are legal, put with the int variable n is not; an
// integral value would also need a cast to become a string (6.16).
// This is one of six tests, one for each of these methods; the others are
// the tests test_illegal_mailbox_param_* of this directory for the other
// five methods.
// Icarus Verilog 13.0 does not support a parameterized mailbox; its syntax
// error on the declaration does not count.
// The design is accepted by Verilator 5.054.

module test_illegal_mailbox_param_put_int_into_string;
  mailbox #(string) box = new();
  string s = "word";
  int n = 5;
  int r;

  initial begin
    box.put("text");
    box.put(s);
    box.put(n);   // illegal
  end
endmodule

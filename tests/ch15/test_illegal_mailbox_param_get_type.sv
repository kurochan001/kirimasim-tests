/*
:name: test_illegal_mailbox_param_get_type
:description: get on a mailbox parameterized with string cannot take an int variable, a type mismatch that the compiler reports (IEEE 1800-2023 Section 15.4.9)
:tags: ch15
:type: elaboration
:lrm: 1800-2023 15.4.9 15.4.5 13.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: get of a mailbox of strings is given an int variable, whose type is not equivalent to string
:expected_stderr_regex: test_illegal_mailbox_param_get_type\.sv:27:
*/
// IEEE 1800-2023 §15.4.9: for a mailbox parameterized with a type, the
// compiler checks that the arguments of put, try_put, peek, try_peek, get and
// try_get have types equivalent to that type, so a mismatch is an error found
// at compile time instead of at run time (15.4.5). The message argument of
// get is passed by reference, and such an argument needs an equivalent type
// (13.5.2); int is not equivalent to string.

module test_illegal_mailbox_param_get_type;
  mailbox #(string) box = new();
  int v;

  initial begin
    box.put("text");
    box.get(v);                 // illegal: int is not equivalent to string
  end
endmodule

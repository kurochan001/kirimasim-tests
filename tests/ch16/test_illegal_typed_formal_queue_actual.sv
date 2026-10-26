/*
:name: test_illegal_typed_formal_queue_actual
:description: a typed sequence formal of type int is bound to a queue actual, which is not cast compatible with int
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.8.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance of s in a_bad passes the queue q to the formal x of type int
:expected_stderr_regex: test_illegal_typed_formal_queue_actual\.sv:27:
*/
// IEEE 1800-2023 §16.8.1: the self-determined type of the actual of a typed
// formal, other than a sequence or event formal, shall be cast compatible
// with the type of the formal. A queue of int is not cast compatible with
// int, so the instance in a_bad is illegal. The sequence itself is legal.

module test_illegal_typed_formal_queue_actual;
  logic clk = 0, a = 1;
  int q[$];

  sequence s(int x);
    a ##1 (x == 1);
  endsequence

  a_bad: assert property (@(posedge clk) s(q));   // illegal
endmodule

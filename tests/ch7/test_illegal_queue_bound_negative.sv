/*
:name: test_illegal_queue_bound_negative
:description: the right bound of a bounded queue has to be a positive integer; a negative bound is illegal (IEEE 1800-2023 Section 7.10)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the right bound of the queue bad is LAST - 4, which evaluates to -1
:expected_stderr_regex: test_illegal_queue_bound_negative\.sv:32:
*/
// IEEE 1800-2023 §7.10 (Syntax 7-4): the optional right bound of a queue
// dimension, its last index, is a constant expression that shall evaluate
// to a positive integer. The bounded queues q1 and q2, with the smallest
// legal bound 1 and a bound computed from a parameter, are legal, and the
// legal design prints their sizes after two elements are pushed onto each.
// The bound of bad evaluates to -1.
// The 5.052 release accepts the negative bound.

module test_illegal_queue_bound_negative;
  parameter int LAST = 3;
  int q1 [$:1];
  int q2 [$:LAST - 1];
  initial begin
    q1.push_back(5);
    q1.push_back(6);
    q2 = '{7, 8};
    $display("%0d %0d", q1.size(), q2.size());
  end
  int bad [$:LAST - 4];   // illegal: bound -1
endmodule

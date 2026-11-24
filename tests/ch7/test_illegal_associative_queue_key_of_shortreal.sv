/*
:name: test_illegal_associative_queue_key_of_shortreal
:description: An associative index cannot be a queue whose element type is short real
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.8.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the associative index is a queue that contains shortreal elements
:expected_stderr_regex: test_illegal_associative_queue_key_of_shortreal\.sv:16:(?:\d+:)?[^\n]*(?i:associative|index|key|shortreal|floating)
*/
module test_illegal_associative_queue_key_of_shortreal;
  typedef shortreal queue_key[$];
  int lookup[queue_key];
  initial $display("unexpected associative index");
endmodule

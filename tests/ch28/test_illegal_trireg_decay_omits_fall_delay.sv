/*
:name: test_illegal_trireg_decay_omits_fall_delay
:description: A charge decay delay in the third position requires an explicit fall delay
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.16.2.2 28.16.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the charge decay is written in the third position but the preceding fall delay is omitted
:expected_stderr_regex: test_illegal_trireg_decay_omits_fall_delay\.sv:16:(?:\d+:)?[^\n]*(?i:(?:syntax error|expected[^\n]*(?:expression|delay)|missing[^\n]*(?:expression|delay)|invalid[^\n]*delay))
*/
module test_illegal_trireg_decay_omits_fall_delay;
  trireg (medium) #(2, 3, 7) complete;
  trireg (medium) #(2, , 7) missing_fall; // illegal

  initial $display("trireg declarations elaborated");
endmodule

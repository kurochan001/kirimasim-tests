/*
:name: test_illegal_trireg_decay_omits_rise_delay
:description: A charge decay delay in the third position requires an explicit rise delay
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.16.2.2 28.16.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the charge decay is written in the third position but the preceding rise delay is omitted
:expected_stderr_regex: test_illegal_trireg_decay_omits_rise_delay\.sv:16:(?:\d+:)?[^\n]*(?i:(?:syntax error|expected[^\n]*(?:expression|delay)|missing[^\n]*(?:expression|delay)|invalid[^\n]*delay))
*/
module test_illegal_trireg_decay_omits_rise_delay;
  trireg (small) #(3, 5, 11) complete;
  trireg (small) #(, 5, 11) missing_rise; // illegal

  initial $display("trireg declarations elaborated");
endmodule

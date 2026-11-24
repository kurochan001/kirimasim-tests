/*
:name: test_illegal_triggered_output_local_reads_caller_value_before_assignment
:description: Triggered disallows reading an output local before the operand assigns it
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.10 16.8.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the triggered sequence reads an output local before its own assignment
:expected_stderr_regex: test_illegal_triggered_output_local_reads_caller_value_before_assignment\.sv:(?:19|26):(?:\d+:)?[^\n]*(?i:(?:unassigned|uninitialized|before[^\n]*assign|not[^\n]*assign))
*/
module test_illegal_triggered_output_local_reads_caller_value_before_assignment;
  bit clock, start_parent, probe, done;
  int observed;

  sequence read_caller_value(local output int sample);
    @(posedge clock) (probe && sample == 77, sample = observed) // early read
      ##1 done;
  endsequence

  sequence parent;
    int sample;
    @(posedge clock) (start_parent, sample = 77)
      ##1 read_caller_value(sample).triggered;
  endsequence

  invalid_read: cover sequence (parent);
endmodule

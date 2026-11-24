/*
:name: test_illegal_triggered_sequence_reads_preassigned_actual_before_its_own_assignment
:description: A prior assignment of a local by the caller cannot make it readable in a triggered sequence before assignment
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.10 16.9.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the triggered operand reads its formal before the sequence assigns it, despite an earlier assignment in the caller
:expected_stderr_regex: test_illegal_triggered_sequence_reads_preassigned_actual_before_its_own_assignment\.sv:(?:19|25):(?:\d+:)?[^\n]*(?i:(?:local|formal|triggered)[^\n]*(?:unassigned|before[^\n]*assign|read[^\n]*before)|(?:before[^\n]*assign|unassigned)[^\n]*(?:local|formal|triggered))
*/
module test_illegal_triggered_sequence_reads_preassigned_actual_before_its_own_assignment;
  bit clock, start_capture, complete_capture;
  int stimulus;

  sequence inspect(local_data);
    @(posedge clock) (start_capture && local_data == 99, local_data = stimulus) // illegal
      ##1 complete_capture;
  endsequence

  sequence parent;
    int local_data;
    @(posedge clock) (1'b1, local_data = 99) ##1 inspect(local_data).triggered;
  endsequence
  invalid_access: cover sequence (parent);
endmodule

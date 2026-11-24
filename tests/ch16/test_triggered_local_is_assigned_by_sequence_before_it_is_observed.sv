/*
:name: test_triggered_local_is_assigned_by_sequence_before_it_is_observed
:description: A triggered sequence supplies the captured value in place of the earlier local assignment
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.10 16.9.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_triggered_local_is_assigned_by_sequence_before_it_is_observed.expected
*/
`timescale 1ns/1ns
module test_triggered_local_is_assigned_by_sequence_before_it_is_observed;
  bit clock, start_capture, complete_capture, start_check, observe_result;
  int stimulus, recorded, hits;

  function automatic void record_value(int value);
    recorded = value;
    hits++;
  endfunction

  sequence capture(local_data);
    @(posedge clock) (start_capture, local_data = stimulus) ##1 complete_capture;
  endsequence

  sequence propagated;
    int local_data;
    @(posedge clock) (start_check, local_data = 99)
      ##1 capture(local_data).triggered ##1 (observe_result, record_value(local_data));
  endsequence

  observed_sequence: cover sequence (propagated);
  always #5 clock = ~clock;

  initial begin
    #2;
    start_check = 1;
    start_capture = 1;
    stimulus = 29;
    #8;
    start_check = 0;
    start_capture = 0;
    stimulus = 0;
    complete_capture = 1;
    #10;
    complete_capture = 0;
    observe_result = 1;
    #10 $display("recorded=%0d hits=%0d", recorded, hits);
    $finish;
  end
endmodule

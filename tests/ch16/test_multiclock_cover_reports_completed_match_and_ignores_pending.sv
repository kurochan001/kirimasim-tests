/*
:name: test_multiclock_cover_reports_completed_match_and_ignores_pending
:description: A multiclock cover reports a completed match and leaves an unfinished start without a hit
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.13.2 16.13.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_multiclock_cover_reports_completed_match_and_ignores_pending.expected
*/
`timescale 1ns/1ns
module test_multiclock_cover_reports_completed_match_and_ignores_pending;
  bit clock_a, clock_b;
  bit start = 1, reply = 1;
  int hits;

  sequence response;
    @(posedge clock_a) start ##1 @(posedge clock_b) reply;
  endsequence

  cover property (@(posedge clock_a) response) begin
    hits++;
    $display("cover t=%0d", int'($time));
  end

  initial begin
    #3 clock_a = 1;
    #1 clock_a = 0;
    #2 clock_b = 1;
    #1 clock_b = 0;
    #2 clock_a = 1;
    #2 $display("hits=%0d", hits);
    $finish;
  end
endmodule

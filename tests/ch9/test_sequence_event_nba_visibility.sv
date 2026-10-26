/*
:name: test_sequence_event_nba_visibility
:description: a process waiting on a sequence event resumes after the Observed region, so it sees a nonblocking update made at the same clock edge
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_event_nba_visibility.expected
*/
// IEEE 1800-2023 9.4.2.4: a process that uses a sequence instance in an event
// control blocks until the sequence reaches its end point and resumes after
// the Observed region in which the end point is detected. The sequence
// a ##1 b ends at the posedge at 21, where b is sampled as 1. An always_ff
// makes v <= b in the NBA region of the same edge, before Observed, so the
// resumed process reads v as 1. A tool that resumes in the Active or Inactive
// region, before the nonblocking update, prints v=0.

`timescale 1ns/1ns

module test_sequence_event_nba_visibility;
  logic a = 0, b = 0, clk = 0, v = 0;

  sequence seq2;
    @(posedge clk) a ##1 b;
  endsequence

  always_ff @(posedge clk) v <= b;

  initial begin
    @(seq2);
    $display("resume t=%0d v=%b", $time, v);
  end

  initial begin
    a = 1;
    #10 clk = 1;
    #10 b = 1;
    clk = 0;
    #1 clk = 1;
    #10 $finish;
  end
endmodule

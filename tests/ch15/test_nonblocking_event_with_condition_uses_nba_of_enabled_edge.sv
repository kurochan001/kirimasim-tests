/*
:name: test_nonblocking_event_with_condition_uses_nba_of_enabled_edge
:description: A single conditional nonblocking trigger skips a disabled edge and is delivered in the enabled edge NBA region
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.5.1 9.4.2 4.4.2.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nonblocking_event_with_condition_uses_nba_of_enabled_edge.expected
*/
`timescale 1ns/1ns
module test_nonblocking_event_with_condition_uses_nba_of_enabled_edge;
  bit clock, enabled;
  event scheduled;
  time fired = 0;

  initial @(scheduled) fired = $time;

  initial begin
    #1;
    ->> @(posedge clock iff enabled) scheduled;
    $display("registration=%0d", $time);
  end

  initial begin
    #2 clock = 1;
    #1 $display("disabled fired=%0d", fired);
    clock = 0;
    enabled = 1;
    #2 clock = 1;
    #0 $display("inactive triggered=%b fired=%0d", scheduled.triggered, fired);
    #1 $display("next triggered=%b fired=%0d", scheduled.triggered, fired);
    $finish(0);
  end
endmodule

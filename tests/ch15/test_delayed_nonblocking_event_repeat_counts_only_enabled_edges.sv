/*
:name: test_delayed_nonblocking_event_repeat_counts_only_enabled_edges
:description: A conditional event control on a nonblocking trigger counts only enabled edges without suspending the caller
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.5.1 9.4.2 9.4.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_delayed_nonblocking_event_repeat_counts_only_enabled_edges.expected
*/
`timescale 1ns/1ns
module test_delayed_nonblocking_event_repeat_counts_only_enabled_edges;
  bit clock, enabled;
  event first_enabled, second_enabled;
  time first_tick = 0, second_tick = 0;

  initial @(first_enabled) first_tick = $time;
  initial @(second_enabled) second_tick = $time;

  initial begin
    #1;
    ->> @(posedge clock iff enabled) first_enabled;
    ->> repeat (2) @(posedge clock iff enabled) second_enabled;
    $display("scheduled=%0d first=%0d second=%0d", $time, first_tick, second_tick);
  end

  initial begin
    #2 clock = 1;
    #1;
    clock = 0;
    enabled = 1;
    #1 clock = 1;
    #1;
    clock = 0;
    enabled = 0;
    $display("after one enabled first=%0d second=%0d", first_tick, second_tick);
    #1 clock = 1;
    #1;
    clock = 0;
    enabled = 1;
    #1 clock = 1;
    #1 $display("after two enabled first=%0d second=%0d", first_tick, second_tick);
    $finish(0);
  end
endmodule

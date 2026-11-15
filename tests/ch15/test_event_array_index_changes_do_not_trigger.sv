/*
:name: test_event_array_index_changes_do_not_trigger
:description: changing the index of an event array in an event control does not wake the waiting process; explicit event triggers still wake the selected and control waiters
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.5.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_array_index_changes_do_not_trigger.expected
*/
// IEEE 1800-2023 15.5.1 says changing an event-array index in an event
// control does not trigger the event. The dynamic waiter blocks on ev[idx]
// with idx initially zero. A control waiter blocks on ev[1]. The producer
// allows the waiters to start, changes idx to one and back to zero without
// triggering either event, and observes that both wake counts remain zero.
// It then explicitly triggers ev[0] and ev[1] on distinct time steps.
// These controls prove the waiters are live and distinguish the elements.
// All observations occur one time unit after the change or trigger, so
// active-region ordering cannot change a displayed count. Restoring idx
// before either event is triggered avoids depending on retargeting rules.
// Icarus Verilog 13.0 does not support event arrays.
// At seeds 1 and 73, the 5.054 release of Verilator reproduces the output.

`timescale 1ns/1ps
module test_event_array_index_changes_do_not_trigger;
  event ev[2];
  int idx = 0;
  int dynamic_wakes = 0, fixed_wakes = 0;

  initial begin
    fork
      begin
        @(ev[idx]);
        dynamic_wakes++;
      end
      begin
        @(ev[1]);
        fixed_wakes++;
      end
    join_none
    #1 idx = 1;
    #1;
    $display("index1 dynamic=%0d fixed=%0d", dynamic_wakes, fixed_wakes);
    idx = 0;
    #1;
    $display("index0 dynamic=%0d fixed=%0d", dynamic_wakes, fixed_wakes);
    -> ev[0];
    #1;
    $display("event0 dynamic=%0d fixed=%0d", dynamic_wakes, fixed_wakes);
    -> ev[1];
    #1;
    $display("event1 dynamic=%0d fixed=%0d", dynamic_wakes, fixed_wakes);
  end
endmodule

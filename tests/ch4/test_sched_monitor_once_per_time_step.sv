/*
:name: test_sched_monitor_once_per_time_step
:description: $monitor prints at most one line per time step, with the values at its end, and nothing in a step where its arguments do not change (IEEE 1800-2023 Section 4.4.2.9)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.9 21.2.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_monitor_once_per_time_step.expected
*/
// IEEE 1800-2023 §21.2.3: $monitor prints its arguments when one of them
// changes, at the end of the time step (§4.4.2.9). In the first step x changes
// four times, by blocking writes, after #0 and by a nonblocking write, and one
// line shows the last value. At time 1 x is written with its own value and
// nothing is printed; at time 2 it changes.
// The monitor of Verilator 5.052 prints the value from before the writes
// after #0 (docs/simulator-differences.md).

`timescale 1ns/1ns

module test_sched_monitor_once_per_time_step;
  int x = 0;
  initial begin
    $monitor("%0t: x=%0d", $time, x);
    x = 1;
    x = 2;
    #0 x = 3;
    x <= 4;
    #1 x = 4;
    #1 x = 5;
  end
endmodule

/*
:name: test_pli_callbacks_are_evaluation_events
:description: Registered PLI callbacks are evaluation events of the time slot they are scheduled in: each runs at its own control point among the events of that slot, sees the values the earlier events left, and a value it writes is an update event that wakes the design in the same slot (IEEE 1800-2023 Section 4.3)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.3 4.10 38.36.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_pli_callbacks_are_evaluation_events.c
:expected_stdout: @test_pli_callbacks_are_evaluation_events.expected
*/
// IEEE 1800-2023 §4.3: the evaluation events of the simulation include PLI
// callbacks, the points where the kernel calls PLI application routines; a
// change of a variable is an update event, and the processes sensitive to it
// are evaluated. §4.10 (Table 4-1) and §38.36.2: a cbAfterDelay callback
// runs in the Pre-Active region of its time slot, a cbReadWriteSynch
// callback in the Pre-NBA or the Post-NBA region, after the Active region,
// and a cbReadOnlySynch callback in the Postponed region.
// $vt_register, called at 0, registers the three callbacks for time 5. At 5:
// - Pre-Active: the cbAfterDelay callback sees v=0 and n=0, before the
//   design's assignments, and writes 7 to w;
// - Active: that write wakes the process waiting for a change of w, which
//   prints w=7 at 5; the other process sets v = 1 and schedules n <= 2;
// - Pre-NBA or Post-NBA: the cbReadWriteSynch callback sees v=1 (it does
//   not print n, which depends on which of the two regions it is);
// - Postponed: the cbReadOnlySynch callback sees v=1, n=2 and w=7.
// A kernel that ran the callbacks outside the time slot, or did not treat
// the write of a callback as an update event, would print other values or
// no line for the design at 5.
// Icarus Verilog 13.0 produces this output; the 5.054 release of Verilator
// does not support user-defined system tasks.

`timescale 1ns/1ns

module test_pli_callbacks_are_evaluation_events;
  int v = 0, n = 0, w = 0;

  initial begin
    $vt_register;
    #5 v = 1;
    n <= 2;
  end

  initial begin
    @(w);
    $display("design at %0t: woken by w=%0d", $time, w);
  end
endmodule

/*
:name: test_clocking_event_cycle_delay
:description: The clocking block event comes after the clock edge processes, ## waits for clocking events of the default clocking, and ##0 waits only when no event has occurred yet (IEEE 1800-2023 Section 14.10)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.10 14.11 14.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_event_cycle_delay.expected
*/
// IEEE 1800-2023 §14.10: a clocking block triggers its event in the Observed
// region, so a process waiting on the clocking block runs after the processes
// woken directly by the clock edge and sees what they wrote. §14.11, §14.12:
// ##n waits for n events of the default clocking; started between events, ##1
// waits only until the next one. ##0 does not wait when the clocking event has
// already occurred in the current time step, and otherwise waits for the next
// event.

`timescale 1ns/1ns

module test_clocking_event_cycle_delay;
  logic clk = 0;
  int edges = 0;
  int seen = 0;
  int mismatches = 0;

  always #5 clk = ~clk;   // posedges at 5, 15, 25, ...

  default clocking cb @(posedge clk);
  endclocking

  always @(posedge clk) edges++;
  always @(cb) begin
    seen++;
    if (seen != edges) mismatches++;
  end

  initial begin
    #2;
    ##1;
    $display("%0d: after ##1 started at 2", $time);
    ##0;
    $display("%0d: after ##0 at a clocking event", $time);
    ##3;
    $display("%0d: after ##3", $time);
    #3;
    ##0;
    $display("%0d: after ##0 between events", $time);
    #1;
    $display("%0d: edges=%0d seen=%0d mismatches=%0d", $time, edges, seen, mismatches);
    $finish;
  end
endmodule

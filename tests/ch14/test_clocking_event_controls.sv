/*
:name: test_clocking_event_controls
:description: @(cb) waits for the clocking event, and @(posedge cb.d) and @(negedge cb.d) wait for changes of the value sampled at the clocking events, so they resume only at clock edges (IEEE 1800-2023 Section 14.15)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.15 14.7 14.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_event_controls.expected
*/
// IEEE 1800-2023 §14.15: an event control on a clocking block waits for its
// clocking event, and one on a clocking block input waits for a change of the
// input's sampled value, so it can resume only at a clocking event. §14.13:
// d is sampled 2 time units before each rising edge. d is 1 at 4, so the
// sample at 3 for the edge at 5 is 0, and cb.d is 0 at 5. At 15 the sample at
// 13 is 1, so @(posedge cb.d) resumes at 15. d is 0 at 20, so the sample at 23
// for the edge at 25 is 0 and @(negedge cb.d) resumes at 25.

`timescale 1ns/1ns

module test_clocking_event_controls;
  logic clk = 0, d = 0;

  always #5 clk = ~clk;

  clocking cb @(posedge clk);
    input #2 d;
  endclocking

  initial begin
    @(cb);
    $display("t=%0t @(cb)", $time);
    @(posedge cb.d);
    $display("t=%0t posedge cb.d %b", $time, cb.d);
    @(negedge cb.d);
    $display("t=%0t negedge cb.d %b", $time, cb.d);
    $finish;
  end

  initial begin
    #4 d = 1;
    #16 d = 0;
  end
endmodule

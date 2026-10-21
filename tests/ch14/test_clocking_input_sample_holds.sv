/*
:name: test_clocking_input_sample_holds
:description: A clocking block input keeps the value sampled at the last clocking event between events (IEEE 1800-2023 Section 14.13)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.13 14.4 14.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_input_sample_holds.expected
*/
// IEEE 1800-2023 §14.13: the input of a clocking block takes the value of its
// signal at each clocking event and keeps it until the next event, so reading
// the clockvar between events gives the sampled value and not the current
// value of the signal. A block with no input skew samples one step before
// the event (§14.4). d is 3 at the edge at 5 and is changed to 7 at 7, but
// cb.d stays 3 at 8 and at 14 and becomes 7 only at the edge at 15.

`timescale 1ns/1ns

module test_clocking_input_sample_holds;
  logic clk = 0;
  logic [3:0] d = 0;

  always #5 clk = ~clk;   // posedges at 5, 15

  clocking cb @(posedge clk);
    input d;
  endclocking

  initial begin
    #3 d = 4'h3;
    @(cb);
    $display("%0d: d=%h", $time, cb.d);
    #2 d = 4'h7;
    #1 $display("%0d: d=%h", $time, cb.d);
    #6 $display("%0d: d=%h", $time, cb.d);
    @(cb);
    $display("%0d: d=%h", $time, cb.d);
    $finish;
  end
endmodule

/*
:name: test_clocking_event_iff
:description: A clocking event may be a clock edge gated by an iff condition, so the clocking block has no event while the condition is false (IEEE 1800-2023 Section 14.3)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.3 9.4.2.3 14.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_event_iff.expected
*/
// IEEE 1800-2023 §14.3: the clocking event of a clocking block is an event
// expression, which §9.4.2.3 lets a condition gate with iff. The block cb
// therefore has an event at the posedge at 15, when en is 1, and none at the
// posedge at 5, when en is 0, nor after en returns to 0. §14.13: the input d
// is sampled at the clocking event, so cb.d keeps 5 after d changes to 9.

`timescale 1ns/1ns

module test_clocking_event_iff;
  logic clk = 0;
  logic en = 0;
  logic [3:0] d = 0;

  always #5 clk = ~clk;

  clocking cb @(posedge clk iff en);
    input d;
  endclocking

  initial begin
    #3 d = 4'h5;
    #5 en = 1;
    @(cb);
    $display("%0d: d=%h", $time, cb.d);
    en = 0;
    #3 d = 4'h9;
    #10 $display("%0d: d=%h, no more event", $time, cb.d);
    $finish;
  end
endmodule

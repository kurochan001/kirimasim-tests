/*
:name: test_assertion_label
:description: a concurrent assertion may carry a preceding label, and the labelled assertion elaborates and runs beside the design (IEEE 1800-2023 9.3.5)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertion_label.expected
*/
// IEEE 1800-2023 §9.3.5: a concurrent assertion may have a label before it,
// as in a1: assert property (...). The test gives the assertion a label,
// checks a property that holds at every posedge of a clock, and prints a
// counter that another process increments on those edges. The run reaches
// 6 ns with three posedges and prints n=3, so the labelled assertion
// elaborates and does not stop or change the design. A tool that rejects the
// label fails to build the test. Icarus Verilog 13.0 has no concurrent
// assertions, so the expected output lists Verilator 5.052.

`timescale 1ns/1ps

module test_assertion_label;
  bit clk = 0;
  int n = 0;

  always #1 clk = ~clk;
  always @(posedge clk) n++;

  a1: assert property (@(posedge clk) n >= 0);

  initial begin
    #6 $display("count=%0d", n);
    $finish;
  end
endmodule

/*
:name: test_clocking_input_expression_skew
:description: An input clockvar that names an expression is evaluated its skew before the clocking event, not at the event (IEEE 1800-2023 Sections 14.4, 14.5)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.4 14.5 14.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_input_expression_skew.expected
*/
// IEEE 1800-2023 §14.5: a clockvar may stand for an expression, here a + b.
// §14.4: the clockvar samples the value of that expression at the clocking
// event minus its own skew, so two clockvars for the same expression can hold
// different values. a is 1 and b is 2 before the edge at 5: the clockvar with
// skew #4 samples a + b at 1 and gets 1, and the clockvar with no skew
// samples at the edge and gets 3. Before the edge at 15 a is 4 and b is 1,
// and the two clockvars get 3 and 5.

`timescale 1ns/1ns

module test_clocking_input_expression_skew;
  logic clk = 0;
  logic [3:0] a = 0;
  logic [3:0] b = 0;

  always #5 clk = ~clk;   // posedges at 5, 15

  clocking cb @(posedge clk);
    input #4 early = a + b;
    input late = a + b;
  endclocking

  initial begin
    #0.5 a = 1;
    #1 b = 2;
    @(cb);
    $display("%0d: early=%0d late=%0d now=%0d", $time, cb.early, cb.late, a + b);
    #6.5 a = 4;
    #1 b = 1;
    @(cb);
    $display("%0d: early=%0d late=%0d now=%0d", $time, cb.early, cb.late, a + b);
    $finish;
  end
endmodule

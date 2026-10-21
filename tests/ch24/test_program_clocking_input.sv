/*
:name: test_program_clocking_input
:description: A program may contain a clocking block, whose input skew samples its input port before the clocking event (IEEE 1800-2023 Sections 24.3, 14.3 and 14.4)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3 14.3 14.4 14.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_clocking_input.expected
*/
// IEEE 1800-2023 §24.3: a program can declare the clocking blocks of a design
// element. §14.3: cb has the clocking event posedge clk. §14.4: its input skew
// #2 samples d two time units before each clocking event, so the value at 5 is
// the 0 from before d rises at 4, and the value at 15 is the 1 from before d
// falls at 16. §14.13: the process waiting on cb resumes after the sampled
// values are updated.

`timescale 1ns/1ns

program p_in(input logic clk, input logic d);
  clocking cb @(posedge clk);
    input #2 d;
  endclocking

  initial begin
    @(cb);
    $display("%0d: d=%b", $time, cb.d);
    @(cb);
    $display("%0d: d=%b", $time, cb.d);
  end
endprogram

module test_program_clocking_input;
  logic clk = 0;
  logic d = 0;

  always #5 clk = ~clk;

  p_in p(.clk(clk), .d(d));

  initial begin
    #4 d = 1;
    #12 d = 0;
    #20 $finish;
  end
endmodule

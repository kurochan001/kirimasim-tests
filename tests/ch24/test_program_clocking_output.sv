/*
:name: test_program_clocking_output
:description: A program may contain a clocking block, whose output skew delays a drive of the program's output port (IEEE 1800-2023 Sections 24.3, 14.3 and 14.16)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3 14.3 14.16 14.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_clocking_output.expected
*/
// IEEE 1800-2023 §24.3: a program can declare the clocking blocks of a design
// element. §14.3: the clocking block cb has the clocking event posedge clk.
// §14.16: the drive cb.q <= 1 waits for the clocking event and then matures
// its output skew #2, so q changes at 7. §14.13: the process resumes after the
// clocking event and sees the drive only after its skew.

`timescale 1ns/1ns

program p_clk(input logic clk, output logic q = 0);
  clocking cb @(posedge clk);
    output #2 q;
  endclocking

  initial begin
    @(cb);
    cb.q <= 1;
    #1 $display("%0d: q=%b", $time, q);
    #2 $display("%0d: q=%b", $time, q);
  end
endprogram

module test_program_clocking_output;
  logic clk = 0;
  logic q;

  always #5 clk = ~clk;

  p_clk p(.clk(clk), .q(q));

  initial #20 $finish;
endmodule

/*
:name: test_program_clocking_default_skew
:description: The default skews of a clocking block in a program apply to its input and output signals, sampling an input before the clocking event and delaying a drive by its output skew (IEEE 1800-2023 Sections 14.3, 14.4 and 14.16)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3 14.3 14.4 14.16 14.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_clocking_default_skew.expected
*/
// IEEE 1800-2023 §24.3: a program can declare a clocking block. §14.3: the
// default statement of cb gives every input a skew of #1 and every output a
// skew of #2, and posedge clk is the clocking event. §14.4: the input d is
// sampled one time unit before each event, so at 5 it holds the 1 written at
// 4 and at 15 the 0 written at 12. §14.16: the drive cb.q <= 1 made after the
// event at 5 reaches q at 7. §14.13: the process reading cb resumes after the
// sampled values are updated.

`timescale 1ns/1ns

program p_clk(input logic clk, input logic d, output logic q);
  clocking cb @(posedge clk);
    default input #1 output #2;
    input d;
    output q;
  endclocking

  initial begin
    @(cb);
    $display("%0d: d=%b q=%b", $time, cb.d, q);
    cb.q <= 1;
    @(cb);
    $display("%0d: d=%b q=%b", $time, cb.d, q);
    $finish;
  end
endprogram

module test_program_clocking_default_skew;
  logic clk = 0;
  logic d = 0;
  logic q = 0;

  always #5 clk = ~clk;

  p_clk p(.clk(clk), .d(d), .q(q));

  initial begin
    #4 d = 1;
    #8 d = 0;
  end
endmodule

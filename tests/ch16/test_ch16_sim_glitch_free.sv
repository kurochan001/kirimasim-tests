/*
:name: test_ch16_sim_glitch_free
:description: a concurrent assertion is evaluated once for each clean clock tick, so a clock that rises once in every time step gives one evaluation per rise (IEEE 1800-2023 Section 16.5)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ch16_sim_glitch_free.expected
*/
// IEEE 1800-2023 §16.5: the clocking event of a concurrent assertion should
// be glitch-free and only transition once during any time step. The clock
// here is a clean divide-by-two: it rises at 5, 15, 25 and 35, once in each
// time step, so the assertion is evaluated exactly once at each of those
// ticks and its pass statement runs four times. §16.5 also says that the
// behavior is undefined when the clocking event transitions more than once
// in a time step, so this test does not put a glitched clock in its expected
// output. The measured behavior with two rises in one time step is recorded
// in notes/ch16-sim.md.
// Icarus Verilog 13.0 has no concurrent assertions, so it has no expected
// output of its own.

`timescale 1ns/1ns

module test_ch16_sim_glitch_free;
  logic clk = 0;
  int evaluations = 0;

  always #5 clk = ~clk;

  a1: assert property (@(posedge clk) 1'b1) evaluations++;

  initial begin
    #40;
    $display("clean clock evaluations=%0d", evaluations);
    $finish;
  end
endmodule

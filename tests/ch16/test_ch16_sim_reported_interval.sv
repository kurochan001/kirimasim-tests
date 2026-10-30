/*
:name: test_ch16_sim_reported_interval
:description: a failing attempt of a ##2 b covers the ticks from the start of the attempt to the tick that ends it, and the times the test prints are those two ticks (IEEE 1800-2023 Section 16.9.4)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.4 16.9.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ch16_sim_reported_interval.expected
*/
// IEEE 1800-2023 §16.9.4: a tool message that reports the starting or ending
// time step of an evaluation attempt shall be consistent with the interval
// of the attempt; it may also report the later time step in which the message
// is written. go and a are sampled true only at the tick at 5, so the
// implication starts one attempt there; b is sampled false at the tick two
// ticks later, 25, so the attempt covers the interval from 5 to 25 and the
// fail action runs in the Observed region of 25. The cover c_start records
// the start tick in the same way the action block of a failing attempt would
// report it, and the fail action prints both ends with
// %t, so the test does not depend on the wording, file name or line number of
// a tool's own assertion message.
// Icarus Verilog 13.0 has no concurrent assertions, so it has no expected
// output of its own.

`timescale 1ns/1ns

module test_ch16_sim_reported_interval;
  logic clk = 0;
  logic go = 0;
  logic a = 0;
  logic b = 0;
  time start;

  always #5 clk = ~clk;

  c_start: cover property (@(posedge clk) a) start = $time;

  a1: assert property (@(posedge clk) go |-> a ##2 b)
    else $display("attempt %0t to %0t", start, $time);

  initial begin
    go = 1;
    a = 1;
    #8 go = 0;
    #4 a = 0;
    #30;
    $display("done");
    $finish;
  end
endmodule

/*
:name: test_default_disable_iff
:description: default disable iff gives a disable condition to every concurrent assertion of the module that has no disable iff of its own; an explicit disable iff, including disable iff (1'b0), takes its place (IEEE 1800-2023 Section 16.15)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.15 16.12 16.14.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_default_disable_iff.expected
*/
// IEEE 1800-2023 §16.15: the module declares default disable iff rst, wherever
// in the module. a_default has no disable iff, so rst disables it (rule b);
// a_own has disable iff (rst1), which is used instead of the default (rule
// a); a_never has disable iff (1'b0), the way to cancel the default. All three
// check a |=> b with a 1 and b 0, so an attempt that is not disabled fails one
// tick after it starts (16.12). The attempt started at 5 runs while rst is 1
// and rst1 is 0; the one started at 25 runs while rst is 0 and rst1 is 1. The
// fail actions count the failures (16.14.1), printed after each attempt.

`timescale 1ns/1ns

module test_default_disable_iff;
  logic clk = 0, a = 0, b = 0, rst = 0, rst1 = 0;
  int f_default = 0, f_own = 0, f_never = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, 35

  a_default: assert property (@(posedge clk) a |=> b) else f_default++;
  a_own: assert property (@(posedge clk) disable iff (rst1) a |=> b) else f_own++;
  a_never: assert property (@(posedge clk) disable iff (1'b0) a |=> b) else f_never++;

  default disable iff rst;

  initial begin
    a = 1; rst = 1;           // attempt at 5, checked at 15
    #10 a = 0;
    #8 $display("%0d: default %0d, own %0d, never %0d", $time, f_default, f_own, f_never);
    #2 a = 1; rst = 0; rst1 = 1;   // attempt at 25, checked at 35
    #10 a = 0;
    #8 $display("%0d: default %0d, own %0d, never %0d", $time, f_default, f_own, f_never);
    $finish;
  end
endmodule

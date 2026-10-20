/*
:name: test_specify_condition_unknown_true
:description: The condition of a state-dependent path is treated as true while it evaluates to x or z, so the path's own delay applies, not the ifnone delay (IEEE 1800-2023 Section 30.4.4.1)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.4.4.1 30.4.4.2 30.4.4.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_specify_condition_unknown_true.expected
*/
// IEEE 1800-2023 §30.4.4.1: a conditional expression that evaluates to x or z
// is treated as true. The buffer has a path delay of 2 while s is true and of
// 7 otherwise (ifnone, 30.4.4.4). a changes at 10 with s = 1, at 30 with
// s = x, at 50 with s = z and at 70 with s = 0, so y follows after 2, 2, 2
// and 7.

`timescale 1ns/1ns

module test_specify_condition_unknown_true_buf(output y, input a, input s);
  buf (y, a);
  specify
    if (s) (a => y) = 2;
    ifnone (a => y) = 7;
  endspecify
endmodule

module test_specify_condition_unknown_true;
  reg a = 0, s = 1;
  wire y;

  test_specify_condition_unknown_true_buf u(y, a, s);

  always @(y) if ($time >= 10) $display("%0d: y=%b", $time, y);

  initial begin
    #10 a = 1;              // s=1: y at 12
    #10 s = 1'bx;
    #10 a = 0;              // 30, s=x: y at 32
    #10 s = 1'bz;
    #10 a = 1;              // 50, s=z: y at 52
    #10 s = 0;
    #10 a = 0;              // 70, s=0: y at 77
    #10 $finish;
  end
endmodule

/*
:name: test_specify_condition_lsb
:description: The condition of a state-dependent path that has more than one bit is decided by its least significant bit alone (IEEE 1800-2023 Section 30.4.4.1)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.4.4.1 30.4.4.2 30.4.4.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_condition_lsb.expected
*/
// IEEE 1800-2023 §30.4.4.1: when the conditional expression of a path has more
// than one bit, its least significant bit is the result. The buffer has a
// path delay of 2 while sel is true and of 7 otherwise (ifnone, 30.4.4.4). a
// changes at 10 with sel 2'b01 (true), at 30 with 2'b10 (false, although the
// value is not zero) and at 50 with 2'b11 (true).

`timescale 1ns/1ns

module test_specify_condition_lsb_buf(output y, input a, input [1:0] sel);
  buf (y, a);
  specify
    if (sel) (a => y) = 2;
    ifnone (a => y) = 7;
  endspecify
endmodule

module test_specify_condition_lsb;
  reg a = 0;
  reg [1:0] sel = 2'b01;
  wire y;

  test_specify_condition_lsb_buf u(y, a, sel);

  always @(y) if ($time >= 10) $display("%0d: y=%b", $time, y);

  initial begin
    #10 a = 1;              // sel=01: y at 12
    #10 sel = 2'b10;
    #10 a = 0;              // 30, sel=10: y at 37
    #10 sel = 2'b11;
    #10 a = 1;              // 50, sel=11: y at 52
    #10 $finish;
  end
endmodule

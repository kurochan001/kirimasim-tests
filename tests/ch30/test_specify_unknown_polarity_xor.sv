/*
:name: test_specify_unknown_polarity_xor
:description: Full and parallel paths without a polarity operator have unknown polarity, so a rise or a fall at the source can cause a rise, a fall or no change at the destination, and each change uses the delay of its own direction (IEEE 1800-2023 Section 30.4.7.1)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.4.7.1 30.4.5 30.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_unknown_polarity_xor.expected
*/
// IEEE 1800-2023 §30.4.7.1: a full (*>) or parallel (=>) path (30.4.5)
// written without + or - has unknown polarity: a rise or a fall at its
// source can make the destination rise, fall or not change. With rise delay
// 3 and fall delay 7 (30.5.1), each change of an output takes the delay of
// its own direction. The xor output rises 3 after a rises at 10 and 3 after
// a falls at 30, and falls 7 after b rises at 20 and 7 after b falls at 40:
// at 13, 33, 27 and 47. The and output does not change when a rises at 10 or
// when b falls at 40; it rises at 23 and falls at 37. Changes before 10,
// from the initial values, are not logged.

`timescale 1ns/1ns

module test_specify_unknown_polarity_xor_cell (input a, input b, output y);
  xor (y, a, b);
  specify
    (a, b *> y) = (3, 7);
  endspecify
endmodule

module test_specify_unknown_polarity_and_cell (input a, input b, output y);
  and (y, a, b);
  specify
    (a => y) = (3, 7);
    (b => y) = (3, 7);
  endspecify
endmodule

module test_specify_unknown_polarity_xor;
  reg a = 0, b = 0;
  wire yx, ya;
  string log_x = "", log_a = "";

  test_specify_unknown_polarity_xor_cell ux(a, b, yx);
  test_specify_unknown_polarity_and_cell ua(a, b, ya);

  always @(yx) if ($time >= 10) log_x = {log_x, $sformatf(" %0t:%b", $time, yx)};
  always @(ya) if ($time >= 10) log_a = {log_a, $sformatf(" %0t:%b", $time, ya)};

  initial begin
    #10 a = 1;
    #10 b = 1;
    #10 a = 0;
    #10 b = 0;
    #20 $display("xor:%s", log_x);
    $display("and:%s", log_a);
  end
endmodule

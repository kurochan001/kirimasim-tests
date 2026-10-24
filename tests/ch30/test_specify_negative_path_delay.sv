/*
:name: test_specify_negative_path_delay
:description: A path delay expression whose value is negative, from a specparam or from an arithmetic expression, is used as a delay of zero while the other delay of the path keeps its value (IEEE 1800-2023 Section 30.5.1)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_negative_path_delay.expected
*/
// IEEE 1800-2023 §30.5.1: a path delay expression that results in a negative
// value is treated as zero. The path to y1 has the rise delay tn, a specparam
// of -3, and the fall delay 4, so y1 rises in the time step in which a rises
// and falls 4 later. The path to y2 has the rise delay 2 and the fall delay
// 1 - 6, which is -5, so y2 rises 2 after a and falls with it. A tool that
// used the magnitude of the delay would print the rise of y1 at 13 and the
// fall of y2 at 25; one that kept the negative value could not schedule the
// change at all. The outputs never change at the same time after time 0.
//
// Icarus Verilog 13.0 does not treat the negative delays as zero: the
// changes that should come without delay never appear.

`timescale 1ns/1ns

module neg_cell1 (input a, output y);
  buf (y, a);
  specify
    specparam tn = -3;
    (a => y) = (tn, 4);
  endspecify
endmodule

module neg_cell2 (input a, output y);
  buf (y, a);
  specify
    (a => y) = (2, 1 - 6);
  endspecify
endmodule

module test_specify_negative_path_delay;
  reg a = 0;
  wire y1, y2;

  neg_cell1 u1 (a, y1);
  neg_cell2 u2 (a, y2);

  always @(y1) if ($time >= 10) $display("%0d: y1=%b", $time, y1);
  always @(y2) if ($time >= 10) $display("%0d: y2=%b", $time, y2);

  initial begin
    #10 a = 1;   // y1 at 10, y2 at 12
    #10 a = 0;   // y2 at 20, y1 at 24
    #10 a = 1;   // y1 at 30, y2 at 32
    #10 $finish;
  end
endmodule

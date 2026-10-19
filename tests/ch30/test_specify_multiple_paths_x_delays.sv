/*
:name: test_specify_multiple_paths_x_delays
:description: (a, b *> q1, q2) declares a full path from every source to every destination, the + and - polarity operators do not change which delay a transition of the output uses, and without explicit x delays a transition to x takes the shortest and a transition from x the longest of the applicable delays (IEEE 1800-2023 Sections 30.4.6, 30.4.7, 30.5.2)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.4.6 30.4.7 30.4.7.2 30.4.7.3 30.5.2 30.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_specify_multiple_paths_x_delays.expected
*/
// IEEE 1800-2023 §30.4.6: (a, b *> q1, q2) = (3, 5) is the four paths from
// a and b to q1 and q2, each with a rise delay of 3 and a fall delay of 5.
// §30.4.7: polarity is an arbitrary annotation and does not affect
// propagation, so the inverting outputs q3 (+=>) and q4 (-=>) use the rise
// delay when they rise and the fall delay when they fall (§30.5.1). §30.5.2:
// with six delays (0->1, 1->0, 0->z, z->1, 1->z, z->0) = (2, 4, 7, 5, 3, 8)
// and none for x, 0->x takes min(7, 2) = 2, x->1 max(5, 2) = 5, 1->x
// min(3, 4) = 3 and x->0 max(8, 4) = 8. The test prints every output change
// from time 10 on, when the outputs have left their initial x; no two outputs
// change at the same time then.

`timescale 1ns/1ns

module paths(input a, b, c, d, output q1, q2, q3, q4, q5);
  and g1(q1, a, b);
  or g2(q2, a, b);
  not g3(q3, c);
  not g4(q4, c);
  buf g5(q5, d);
  specify
    (a, b *> q1, q2) = (3, 5);
    (c +=> q3) = (1, 3);
    (c -=> q4) = (2, 6);
    (d => q5) = (2, 4, 7, 5, 3, 8);
  endspecify
endmodule

module test_specify_multiple_paths_x_delays;
  reg a = 0, b = 0, c = 0, d = 0;
  wire q1, q2, q3, q4, q5;

  paths u(a, b, c, d, q1, q2, q3, q4, q5);

  always @(q1) if ($time >= 10) $display("%0d: q1 = %b", $time, q1);
  always @(q2) if ($time >= 10) $display("%0d: q2 = %b", $time, q2);
  always @(q3) if ($time >= 10) $display("%0d: q3 = %b", $time, q3);
  always @(q4) if ($time >= 10) $display("%0d: q4 = %b", $time, q4);
  always @(q5) if ($time >= 10) $display("%0d: q5 = %b", $time, q5);

  initial begin
    #10 a = 1;
    #10 b = 1;
    #10 a = 0;
    #10 b = 0;
    #10 c = 1;
    #10 c = 0;
    #10 d = 1'bx;
    #20 d = 1;
    #20 d = 1'bx;
    #20 d = 0;
    #20 $finish;
  end
endmodule

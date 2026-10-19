/*
:name: test_specify_path_vs_distributed_delay
:description: When a module has both module path delays and gate delays along the path, the larger of the two is used (IEEE 1800-2023 Section 30.6)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.6 30.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_path_vs_distributed_delay.expected
*/
// IEEE 1800-2023 §30.6: if a module has module path delays and distributed
// delays (delays of the primitives inside it), the larger of the two is used for
// each path. Both paths here have a path delay of 6; the gates on the way to y1
// add up to 2 and those on the way to y2 to 9, so y1 follows a after 6 and y2
// after 9. Transitions before time 10 are not printed.

`timescale 1ns/1ns

module specify_mixed_delays(output y1, output y2, input a);
  wire m1, m2;
  buf #1 g1 (m1, a);
  buf #1 g2 (y1, m1);
  buf #5 g3 (m2, a);
  buf #4 g4 (y2, m2);
  specify
    (a => y1) = 6;
    (a => y2) = 6;
  endspecify
endmodule

module test_specify_path_vs_distributed_delay;
  reg a = 0;
  wire y1, y2;

  specify_mixed_delays u(y1, y2, a);

  always @(y1 or y2) if ($time >= 10) $display("%0d: y1=%b y2=%b", $time, y1, y2);

  initial begin
    #10 a = 1;
    #20 $finish;
  end
endmodule

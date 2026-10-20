/*
:name: test_rtranif_control_and_reduction
:description: rtranif1 and rtranif0 connect their terminals only while the control is 1 or 0, and then with the strength reduced as for rtran (IEEE 1800-2023 Section 28.8)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.8 28.14 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_rtranif_control_and_reduction.expected
*/
// IEEE 1800-2023 §28.8: tranif1 and rtranif1 conduct while their control is
// 1, tranif0 and rtranif0 while it is 0; otherwise the terminals are apart and
// an otherwise undriven terminal is z. The resistive forms reduce a strong
// drive to pull (28.14). a is driven strong 1, and b1 and b0 hang off it
// through rtranif1 and rtranif0 with the same control.

`timescale 1ns/1ns

module test_rtranif_control_and_reduction;
  logic c;
  wire a, b1, b0;

  assign (strong0, strong1) a = 1'b1;
  rtranif1 t1(a, b1, c);
  rtranif0 t0(a, b0, c);

  initial begin
    c = 1'b1;
    #1 $display("c=%b: a=%v b1=%v b0=%v", c, a, b1, b0);
    c = 1'b0;
    #1 $display("c=%b: a=%v b1=%v b0=%v", c, a, b1, b0);
  end
endmodule

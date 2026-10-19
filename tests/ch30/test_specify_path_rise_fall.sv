/*
:name: test_specify_path_rise_fall
:description: A module path with two delays uses the first for rising and the second for falling transitions of the output (IEEE 1800-2023 Section 30.5.1)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.5.1 30.4.2 30.3 30.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_path_rise_fall.expected
*/
// IEEE 1800-2023 §30.3, §30.4.2: a specify block declares module paths from
// input to output ports, such as (a => y). §30.5, §30.5.1: with two delay
// values the first applies to transitions of the output to 1 and the second to
// transitions to 0. So with (3, 5), y rises 3 and falls 5 time units after a
// changes. Transitions before time 10, from the start of simulation, are not
// printed.

`timescale 1ns/1ns

module specify_rise_fall_buf(output y, input a);
  buf (y, a);
  specify
    (a => y) = (3, 5);
  endspecify
endmodule

module test_specify_path_rise_fall;
  reg a = 0;
  wire y;

  specify_rise_fall_buf u(y, a);

  always @(y) if ($time >= 10) $display("%0d: y=%b", $time, y);

  initial begin
    #10 a = 1;
    #10 a = 0;
    #10 a = 1;
    #10 $finish;
  end
endmodule

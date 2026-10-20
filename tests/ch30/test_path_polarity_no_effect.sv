/*
:name: test_path_polarity_no_effect
:description: A module path without a polarity operator has unknown polarity, and the polarity, unknown, positive or negative, does not change how the output of an inverting cell changes: the delay follows the transition of the output (IEEE 1800-2023 Section 30.4.7.1)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.4.7.1 30.4.7 30.4.7.2 30.4.7.3 30.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_path_polarity_no_effect.expected
*/
// IEEE 1800-2023 §30.4.7.1: a path written without + or - has unknown
// polarity: a transition at its source may cause any transition, or none, at
// its destination. §30.4.7: polarity is only a description; how a change
// propagates depends on the logic of the module. The three inverting cells
// differ only in the polarity of their path (30.4.7.2, 30.4.7.3), with a rise
// delay of 2 and a fall delay of 5 (30.5). When a rises at 10, every output
// falls, so all use the fall delay and change at 15; when a falls at 20 they
// rise at 22. The outputs are printed between the changes.

`timescale 1ns/1ns

module test_path_polarity_no_effect_unknown (input a, output y);
  not (y, a);
  specify
    (a => y) = (2, 5);
  endspecify
endmodule

module test_path_polarity_no_effect_positive (input a, output y);
  not (y, a);
  specify
    (a +=> y) = (2, 5);
  endspecify
endmodule

module test_path_polarity_no_effect_negative (input a, output y);
  not (y, a);
  specify
    (a -=> y) = (2, 5);
  endspecify
endmodule

module test_path_polarity_no_effect;
  logic a = 0;
  wire yu, yp, yn;

  test_path_polarity_no_effect_unknown u(a, yu);
  test_path_polarity_no_effect_positive p(a, yp);
  test_path_polarity_no_effect_negative n(a, yn);

  initial begin
    #10 a = 1;
    #4 $display("t=%0t: %b %b %b", $time, yu, yp, yn);
    #2 $display("t=%0t: %b %b %b", $time, yu, yp, yn);
    #4 a = 0;
    #1 $display("t=%0t: %b %b %b", $time, yu, yp, yn);
    #2 $display("t=%0t: %b %b %b", $time, yu, yp, yn);
  end
endmodule

/*
:name: test_mintypmax_expressions
:description: A min:typ:max expression can stand wherever an expression can, as a value and as a delay; one of its three values is used, the same choice for all of them (IEEE 1800-2023 Section 11.11)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.11 9.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mintypmax_expressions.expected
*/
// IEEE 1800-2023 §11.11: three expressions separated by colons in
// parentheses are a min:typ:max expression, which may appear wherever an
// expression can and which takes one of its three values. Which one depends
// on how the tool is run, so the test only shows results that are the same
// for each choice: base is 1, 2 or 3 and scaled ten times as much, and a
// delay of (2:4:6) waits as long as twice base.

`timescale 1ns/1ns

module test_mintypmax_expressions;
  int base, scaled;
  time t0;

  initial begin
    base = (1:2:3);
    scaled = (10:20:30);
    $display("scaled is ten times base: %0d, base in range: %0d", scaled == 10 * base,
             base >= 1 && base <= 3);
    t0 = $time;
    #(2:4:6);
    $display("delay was twice base: %0d", $time - t0 == 2 * base);
  end
endmodule

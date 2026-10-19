/*
:name: test_specify_delay_selection
:description: With paths from two inputs to one output, the delay comes from the input that changed most recently, or the smallest delay when both changed together (IEEE 1800-2023 Section 30.5.3)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.5.3 30.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_delay_selection.expected
*/
// IEEE 1800-2023 §30.5.3: when several module paths lead to an output, the
// active ones are those whose input changed most recently, and among them the
// smallest delay for the transition is used. With (a => y) = (4, 8) and
// (b => y) = (3, 10), a change of a alone gives a rise of 4 or a fall of 8, a
// change of b alone a rise of 3 or a fall of 10, and a and b changing in the
// same time step a rise of 3. Transitions before time 10 are not printed.

`timescale 1ns/1ns

module specify_select_or(output y, input a, input b);
  or (y, a, b);
  specify
    (a => y) = (4, 8);
    (b => y) = (3, 10);
  endspecify
endmodule

module test_specify_delay_selection;
  reg a = 0, b = 0;
  wire y;

  specify_select_or u(y, a, b);

  always @(y) if ($time >= 10) $display("%0d: y=%b", $time, y);

  initial begin
    #10 a = 1;           // y at 14
    #10 a = 0;           // y at 28
    #10 b = 1;           // y at 33
    #10 b = 0;           // y at 50
    #20 a = 1; b = 1;    // 60, both: y at 63
    #10 $finish;
  end
endmodule

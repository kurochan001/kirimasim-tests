/*
:name: test_specify_conditions_both_true
:description: When two state-dependent paths from the same input are active at once, the output changes after the smaller of their delays (IEEE 1800-2023 Section 30.5.3)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.5.3 30.4.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_conditions_both_true.expected
*/
// IEEE 1800-2023 §30.5.3: the active paths to an output are those whose input
// changed last and whose condition, if any, is true; of these, the one with
// the smallest delay for the transition decides. Both paths here come from a
// (30.4.4.2): one with delay 6 under c1, one with delay 3 under c2. a changes
// at 10 with only c1 true (6), at 30 with both true (3) and at 50 with only
// c2 true (3).

`timescale 1ns/1ns

module test_specify_conditions_both_true_buf(output y, input a, input c1, input c2);
  buf (y, a);
  specify
    if (c1) (a => y) = 6;
    if (c2) (a => y) = 3;
  endspecify
endmodule

module test_specify_conditions_both_true;
  reg a = 0, c1 = 1, c2 = 0;
  wire y;

  test_specify_conditions_both_true_buf u(y, a, c1, c2);

  always @(y) if ($time >= 10) $display("%0d: y=%b", $time, y);

  initial begin
    #10 a = 1;              // c1 only: y at 16
    #10 c2 = 1;
    #10 a = 0;              // 30, both: y at 33
    #10 c1 = 0;
    #10 a = 1;              // 50, c2 only: y at 53
    #10 $finish;
  end
endmodule

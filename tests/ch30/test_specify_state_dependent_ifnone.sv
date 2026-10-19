/*
:name: test_specify_state_dependent_ifnone
:description: A state-dependent module path applies its delay while its condition is true, and the ifnone path gives the delay otherwise (IEEE 1800-2023 Section 30.4.4.2)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.4.4.2 30.4.4.4 30.4.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_state_dependent_ifnone.expected
*/
// IEEE 1800-2023 §30.4.4.1, §30.4.4.2: if (s) (a => y) = 2; gives the path from
// a to y a delay of 2 while s is true. §30.4.4.4: ifnone (a => y) = 7; gives the
// delay used when no condition of the path is true. s itself is not a source
// of the path, so a change of s alone does not change y. Transitions before
// time 10 are not printed.

`timescale 1ns/1ns

module specify_state_buf(output y, input a, input s);
  buf (y, a);
  specify
    if (s) (a => y) = 2;
    ifnone (a => y) = 7;
  endspecify
endmodule

module test_specify_state_dependent_ifnone;
  reg a = 0, s = 1;
  wire y;

  specify_state_buf u(y, a, s);

  always @(y) if ($time >= 10) $display("%0d: y=%b", $time, y);

  initial begin
    #10 a = 1;     // s is 1: y at 12
    #5 s = 0;
    #5 a = 0;      // 20, s is 0: y at 27
    #10 a = 1;     // 30: y at 37
    #10 $finish;
  end
endmodule

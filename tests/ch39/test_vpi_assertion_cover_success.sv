/*
:name: test_vpi_assertion_cover_success
:description: A cbAssertionSuccess callback reports a nonvacuous success of a cover property, with the time of the success and the start of its attempt (IEEE 1800-2023 Section 39.4.2)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.4.2 16.14.3 16.12.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_cover_success.c
:expected_stdout: @test_vpi_assertion_cover_success.expected
*/
// IEEE 1800-2023 §39.4.2: a callback placed with vpi_register_assertion_cb
// for cbAssertionSuccess reports a nonvacuous success of a cover property,
// with cb_time and the attemptStartTime of the attempt. §16.14.3: a cover
// property has no failure action, and only a match is a success. §16.12.7: a
// success is nonvacuous when the antecedent matched. The attempt that starts
// at 5, with a and b, matches at 15, where b is 1; the attempt that starts at
// 15 does not match, because b is 0 at 25. The application counts one success.

`timescale 1ns/1ns

module test_vpi_assertion_cover_success;
  logic clk = 0;
  logic a = 0;
  logic b = 0;

  always #5 clk = ~clk;

  c1: cover property (@(posedge clk) a ##1 b);

  initial begin
    $vt_watch;
    a = 1;
    b = 0;
    #10 b = 1;
    #10 a = 0;
    b = 0;
    #20 $vt_report;
    $finish;
  end
endmodule

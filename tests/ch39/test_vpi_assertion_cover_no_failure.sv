/*
:name: test_vpi_assertion_cover_no_failure
:description: A cover property that does not match reports no cbAssertionFailure callback (IEEE 1800-2023 Sections 39.4.2 and 16.14.3)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.4.2 16.14.3 16.9.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_cover_no_failure.c
:expected_stdout: @test_vpi_assertion_cover_no_failure.expected
*/
// IEEE 1800-2023 §16.14.3: a cover property has no failure action; an attempt
// whose sequence does not match is simply not covered. §39.4.2: the assertion
// callbacks report start, success, vacuous success and failure; a cover
// property that does not match therefore reports no cbAssertionFailure. The
// attempts that start at 25 and 35 cannot match, because a is 0. The
// application places only a failure callback and counts none.

`timescale 1ns/1ns

module test_vpi_assertion_cover_no_failure;
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

/*
:name: test_vpi_assertion_cover_start
:description: A cbAssertionStart callback reports the start of every attempt of a cover property, also of an attempt whose sequence cannot match (IEEE 1800-2023 Section 39.4.2)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.4.2 16.14.3 16.9.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_cover_start.c
:expected_stdout: @test_vpi_assertion_cover_start.expected
*/
// IEEE 1800-2023 §39.4.2: a callback placed with vpi_register_assertion_cb
// for cbAssertionStart reports each attempt when it starts. §16.9.2: the cover
// property starts an attempt at every clock tick, also when the first term of
// its sequence is false and the attempt cannot match. The clock ticks at 5,
// 15, 25 and 35, so four attempts start; the application reports each start
// time and the count.

`timescale 1ns/1ns

module test_vpi_assertion_cover_start;
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

/*
:name: test_checker_always_latch
:description: A checker may drive its output with an always_latch procedure, which keeps the output between its assignments (IEEE 1800-2023 Section 17.5)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.5 17.7.1 17.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_always_latch.expected
*/
// IEEE 1800-2023 §17.5: a checker can hold an always_latch procedure, and its
// output formal q can be driven there. §17.7.1: q is assigned only in that
// procedure. The latch keeps q while en is 0: q takes 1 at 2, follows d to 2
// at 3, and keeps 2 after en falls at 5 and d changes to 3 at 6.

`timescale 1ns/1ns

checker chk_latch(input logic en, input logic [3:0] d, output logic [3:0] q);
  always_latch if (en) q = d;
endchecker

module test_checker_always_latch;
  logic en = 0;
  logic [3:0] d = 0;
  logic [3:0] q;

  chk_latch c(.en(en), .d(d), .q(q));

  initial begin
    #1 d = 4'h1;
    #1 en = 1;
    #1 d = 4'h2;
    #1 $display("%0d: q=%h", $time, q);
    en = 0;
    #1 d = 4'h3;
    #1 $display("%0d: q=%h", $time, q);
    $finish;
  end
endmodule

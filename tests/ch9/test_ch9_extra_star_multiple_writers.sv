/*
:name: test_ch9_extra_star_multiple_writers
:description: two always @* processes may write the same variable, unlike always_comb, and both run when their shared input changes (IEEE 1800-2023 Section 9.2.2.2.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ch9_extra_star_multiple_writers.expected
*/
// IEEE 1800-2023 §9.2.2.2.2: always_comb has exclusive target-writing rules,
// including writes made by the functions it calls, while an ordinary
// always @* has no such rule and may share a target with another process.
//
// Both always @* blocks read in and write the shared target v; each also
// writes a marker of its own. When in changes at time 1 both blocks run, so
// both markers become 1. The final value of v is 1 or 2 depending on which
// block wrote last, and the test prints only that it is one of the two
// values a writer can leave, never which writer won. A tool that rejected
// the shared write, as it must for always_comb, would not compile this
// design; a tool that ran only one block would leave one marker at 0.

`timescale 1ns/1ns

module test_ch9_extra_star_multiple_writers;
  int in = 0;
  int a = 0;
  int b = 0;
  int v = 0;

  always @* begin
    a = in;
    v = 1;
  end

  always @* begin
    b = in;
    v = 2;
  end

  initial begin
    #1 in = 1;
    #1 $display("a=%0d b=%0d both_writers_ran=%0d", a, b, (a == 1) && (b == 1));
    $display("v_is_one_of_two=%0d", (v == 1) || (v == 2));
    $finish;
  end
endmodule

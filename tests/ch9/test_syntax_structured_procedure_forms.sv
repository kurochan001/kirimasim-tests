/*
:name: test_syntax_structured_procedure_forms
:description: The initial, always, always_comb, always_latch, always_ff and final procedures of A.6.2 take their bodies and run once, repeatedly, or at the end, with the value each computes (IEEE 1800-2023 Sections 9.2.1 to 9.2.3, A.6.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2 9.2.1 9.2.2.1 9.2.2.2 9.2.2.3 9.2.2.4 9.2.3 A.6.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_structured_procedure_forms.expected
*/
// IEEE 1800-2023 A.6.2: an initial procedure takes a statement or a null
// statement, an always procedure takes a statement, and a final procedure
// takes a function statement. §9.2.1 to §9.2.3: the initial procedure runs
// once, the always procedures run repeatedly, and the final procedure runs
// once at the end.
//
// The test writes each keyword with a different body so that its effect is
// visible: the initial procedure prints the combinational value computed at
// time 0, then changes the input and the latch controls; the general always
// procedure toggles the clock; always_comb recomputes 2+1 = 3 and 5+1 = 6;
// always_latch passes 1 while its enable is high and holds it when the enable
// falls; always_ff counts the two rising edges of the clock; the final
// procedure prints the values left at the end. A second initial procedure
// has the null statement ";" as its body and therefore does nothing.
//
// Icarus Verilog 13.0 rejects the null statement ";" as the body of an
// initial procedure, so the expected output follows the standard and was
// confirmed with Verilator 5.052.

`timescale 1ns/1ns

module test_syntax_structured_procedure_forms;
  logic clk = 0;
  int comb_in = 2;
  int comb_out;
  logic latch_en = 0, latch_in = 0, latch_q = 0;
  int ff_q = 0;
  int counter = 0;

  always #5 clk = ~clk;

  always_comb comb_out = comb_in + 1;

  always_latch if (latch_en) latch_q = latch_in;

  always_ff @(posedge clk) ff_q <= ff_q + 1;

  initial ;

  initial begin
    #1 $display("initial: comb_out=%0d", comb_out);
    comb_in = 5;
    #1 $display("comb after 5: %0d", comb_out);
    latch_en = 1;
    latch_in = 1;
    #1 $display("latch with enable: %b", latch_q);
    latch_en = 0;
    latch_in = 0;
    #1 $display("latch holds: %b", latch_q);
    repeat (2) @(posedge clk);
    #1 $display("ff after 2 edges: %0d", ff_q);
    counter = 3;
    $finish;
  end

  final
    $display("final: comb=%0d latch=%b ff=%0d counter=%0d",
             comb_out, latch_q, ff_q, counter);
endmodule

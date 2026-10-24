/*
:name: test_wired_logic_ambiguous_strength_combinations
:description: on wand and wor nets a signal of ambiguous strength combines with another by taking every pair of their strength levels, so a 0 from strong to pull with a pull 1 gives a 0 from strong to pull on wand and an x on wor (IEEE 1800-2023 Section 28.12.4)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.12.4 28.12.2 21.2.1.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_wired_logic_ambiguous_strength_combinations.expected
*/
// IEEE 1800-2023 §28.12.4: when signals of ambiguous strength combine on a
// wired logic net, every strength level of one signal is combined with
// every level of the other: the stronger one wins, and two of the same
// strength go through the and (wand) or the or (wor) of their values. The
// first signal on each net is a 0 from strong to pull, made by a strong L
// (a bufif1 with an x control, 28.12.2) and a pull 0, and the second is a
// pull 1. On wand, strong 0 with pull 1 gives a strong 0 and pull 0 with
// pull 1 gives a pull 0, so the net is a 0 from strong to pull, which %v
// (21.2.1.4) shows as 650; on wor the second pair gives a pull 1, so the
// net is x with a strong 0 and a pull 1 part, 65X. A strong H with a pull 0
// gives on both nets an x of a pull 0 and a strong 1, 56X, as there the
// stronger level decides every pair.
// Icarus Verilog 13.0 ignores the strengths of the drivers of wand and wor
// nets (see docs/simulator-differences.md); Verilator 5.052 does not build
// these wired nets with three-state drivers.

module test_wired_logic_ambiguous_strength_combinations;
  logic x = 1'bx;
  wand a_l;
  wor o_l;
  wand a_h;
  wor o_h;

  bufif1 l1(a_l, 1'b0, x);
  assign (pull0, pull1) a_l = 1'b0;
  assign (pull0, pull1) a_l = 1'b1;
  bufif1 l2(o_l, 1'b0, x);
  assign (pull0, pull1) o_l = 1'b0;
  assign (pull0, pull1) o_l = 1'b1;

  bufif1 h1(a_h, 1'b1, x);
  assign (pull0, pull1) a_h = 1'b0;
  bufif1 h2(o_h, 1'b1, x);
  assign (pull0, pull1) o_h = 1'b0;

  initial begin
    #1;
    $display("wand, StL + Pu0 with Pu1: %v", a_l);
    $display("wor, StL + Pu0 with Pu1: %v", o_l);
    $display("wand, StH with Pu0: %v", a_h);
    $display("wor, StH with Pu0: %v", o_h);
  end
endmodule

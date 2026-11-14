/*
:name: test_rand_join_depth_one_nonterminals
:description: rand join interleaves the nonterminals of its productions to depth 1, so a nonterminal of one production is generated whole between the items of the other while the items of the two productions do mix (IEEE 1800-2023 Section 18.17.5)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.17.5
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_rand_join_depth_one_nonterminals.expected
*/
// IEEE 1800-2023 §18.17.5: rand join interleaves the productions s1 and s2,
// keeping the order within each, and at each step it interleaves the
// nonterminals to depth 1. Here s1 is a b and s2 is c d, so the interleaved
// symbols are a, b, c and d, and a is itself a nonterminal with the items x
// then y. At depth 1, a is generated whole when it is chosen: x and y come
// next to each other, and every output is one of the six orders of a, b, c
// and d that keep a before b and c before d, with a written as xy: xybcd,
// xycbd, xycdb, cdxyb, cxybd and cxydb. If the generator interleaved deeper,
// c or d could come between x and y. In three of the six orders c or d comes
// between a and b, which shows that the items of the two productions mix
// instead of s1 and s2 being generated one after the other. The order of
// each run is random; the test runs the randsequence 200 times and prints
// whether all outputs were among the six and whether c or d came between a
// and b in at least one of them.
// Icarus Verilog 13.0 does not support randsequence; the 5.054 release of
// the Verilator simulator gives the expected output with both seeds.

module test_rand_join_depth_one_nonterminals;
  string seq;
  bit all_depth_one = 1;
  bit mixed = 0;

  initial begin
    repeat (200) begin
      seq = "";
      randsequence (top)
        top : rand join s1 s2;
        s1 : a b;
        s2 : c d;
        a : x y;
        x : { seq = {seq, "x"}; };
        y : { seq = {seq, "y"}; };
        b : { seq = {seq, "b"}; };
        c : { seq = {seq, "c"}; };
        d : { seq = {seq, "d"}; };
      endsequence
      if (!(seq inside {"xybcd", "xycbd", "xycdb", "cdxyb", "cxybd", "cxydb"}))
        all_depth_one = 0;
      if (seq inside {"xycbd", "xycdb", "cxydb"}) mixed = 1;
    end
    $display("every output keeps a whole among the six orders: %0d", all_depth_one);
    $display("c or d between a and b in some output: %0d", mixed);
  end
endmodule

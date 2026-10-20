/*
:name: test_rand_join_interleaving
:description: rand join interleaves the items of its productions randomly but keeps the order of the items of each production (IEEE 1800-2023 Section 18.17.5)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.17.5 18.17
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_rand_join_interleaving.expected
*/
// IEEE 1800-2023 §18.17.5: top : rand join s1 s2 produces the items of s1, a
// then b, and of s2, c then d, in a random interleaving that keeps a before b
// and c before d: one of six orders. The order itself is random, so the test
// checks that each of 20 runs gives one of the six and prints how many did.

module test_rand_join_interleaving;
  string seq;
  int legal = 0;

  initial begin
    repeat (20) begin
      seq = "";
      randsequence (top)
        top : rand join s1 s2;
        s1 : a b;
        s2 : c d;
        a : { seq = {seq, "a"}; };
        b : { seq = {seq, "b"}; };
        c : { seq = {seq, "c"}; };
        d : { seq = {seq, "d"}; };
      endsequence
      if (seq inside {"abcd", "acbd", "acdb", "cdab", "cabd", "cadb"}) legal++;
      else $display("illegal order %s", seq);
    end
    $display("%0d of 20 orders keep the order within each production", legal);
  end
endmodule

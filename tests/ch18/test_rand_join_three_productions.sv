/*
:name: test_rand_join_three_productions
:description: rand join of three productions keeps the order of the items within each, and rand join with a length bias of 0.0 or 1.0 keeps the same orders (IEEE 1800-2023 Section 18.17.5)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.17.5 18.17
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_rand_join_three_productions.expected
*/
// IEEE 1800-2023 §18.17.5: rand join interleaves the items of two or more
// productions at random but keeps the order of the items of each. So
// rand join s1 s2 s3, with s1 : a b, s2 : c d and s3 : e, gives each item
// once, a before b and c before d, with e anywhere. The real expression
// after rand join, 0.0 or 1.0, only changes how likely each interleaving
// is, so rand join (0.0) s1 s2 and rand join (1.0) s1 s2 still give one of
// the six orders that keep a before b and c before d. Each form runs 20
// times, and the test counts the results that are allowed.

module test_rand_join_three_productions;
  string seq;
  int legal3 = 0, legal_short = 0, legal_long = 0;

  function automatic bit precedes(string s, byte x, byte y);
    int ix = -1, iy = -1;
    for (int i = 0; i < s.len(); i++) begin
      if (s[i] == x) ix = i;
      if (s[i] == y) iy = i;
    end
    return ix >= 0 && iy >= 0 && ix < iy;
  endfunction

  initial begin
    repeat (20) begin
      seq = "";
      randsequence (top)
        top : rand join s1 s2 s3;
        s1  : a b;
        s2  : c d;
        s3  : e;
        a   : { seq = {seq, "a"}; };
        b   : { seq = {seq, "b"}; };
        c   : { seq = {seq, "c"}; };
        d   : { seq = {seq, "d"}; };
        e   : { seq = {seq, "e"}; };
      endsequence
      if (seq.len() == 5 && precedes(seq, "a", "b") && precedes(seq, "c", "d")
          && precedes(seq, "a", "e") + precedes(seq, "e", "a") == 1) legal3++;
    end
    $display("three productions: %0d of 20 keep the order within each", legal3);

    repeat (20) begin
      seq = "";
      randsequence (top2)
        top2 : rand join (0.0) s1 s2;
        s1   : a b;
        s2   : c d;
        a    : { seq = {seq, "a"}; };
        b    : { seq = {seq, "b"}; };
        c    : { seq = {seq, "c"}; };
        d    : { seq = {seq, "d"}; };
      endsequence
      if (seq inside {"abcd", "acbd", "acdb", "cdab", "cabd", "cadb"}) legal_short++;
    end
    $display("rand join (0.0): %0d of 20 keep the order within each", legal_short);

    repeat (20) begin
      seq = "";
      randsequence (top3)
        top3 : rand join (1.0) s1 s2;
        s1   : a b;
        s2   : c d;
        a    : { seq = {seq, "a"}; };
        b    : { seq = {seq, "b"}; };
        c    : { seq = {seq, "c"}; };
        d    : { seq = {seq, "d"}; };
      endsequence
      if (seq inside {"abcd", "acbd", "acdb", "cdab", "cabd", "cadb"}) legal_long++;
    end
    $display("rand join (1.0): %0d of 20 keep the order within each", legal_long);
  end
endmodule

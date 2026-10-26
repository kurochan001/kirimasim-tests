/*
:name: test_rand_join_length_bias
:description: rand join interleaves two production sequences at random while keeping each order, the default value 0.5 does not prefer a length, 0.0 gives the sequences that finish first the higher probability, and 1.0 gives the more interleaved sequences the higher probability (IEEE 1800-2023 Section 18.17.5)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.17.5 18.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_rand_join_length_bias.expected
*/
// IEEE 1800-2023 §18.17.5: top : rand join s1 s2 with s1 : a b and s2 : c d
// gives one of six orders that keep a before b and c before d, and more than
// one of them occurs. The optional expression weights the length of the
// remaining sequences: 0.0 favors the shortest, so after a the second item of
// s1 follows more often and the orders abcd and cdab dominate; 1.0 favors the
// longest, so the four interleaved orders dominate. The default 0.5
// prioritizes no length, so its count of abcd and cdab lies between the two.
// The standard does not fix the probabilities, only this order of preference;
// with 600 calls the sampling error of each count is about 25, so the test
// asks for the three strict inequalities, not for a margin.
// In Verilator 5.052 0.0 and 1.0 are the other way round, so both
// comparisons fail there.

module test_rand_join_length_bias;
  string seq;
  int orders[6];
  int distinct;
  int pure0, pure5, pure1;
  int legal;

  function automatic void note(input string s, inout int n[6]);
    case (s)
      "abcd": n[0]++;
      "acbd": n[1]++;
      "acdb": n[2]++;
      "cdab": n[3]++;
      "cabd": n[4]++;
      "cadb": n[5]++;
    endcase
  endfunction

  function automatic bit legal_order(input string s);
    int ia, ib, ic, id;
    ia = -1;
    ib = -1;
    ic = -1;
    id = -1;
    for (int i = 0; i < s.len(); i++) begin
      if (s[i] == 8'h61) ia = i;
      if (s[i] == 8'h62) ib = i;
      if (s[i] == 8'h63) ic = i;
      if (s[i] == 8'h64) id = i;
    end
    return s.len() == 4 && ia < ib && ic < id;
  endfunction

  task automatic one(input string join_form, inout int pure_count);
    seq = "";
    case (join_form)
      "default": begin
        randsequence (top)
          top : rand join s1 s2;
          s1 : a b;
          s2 : c d;
          a : { seq = {seq, "a"}; };
          b : { seq = {seq, "b"}; };
          c : { seq = {seq, "c"}; };
          d : { seq = {seq, "d"}; };
        endsequence
      end
      "0.0": begin
        randsequence (top0)
          top0 : rand join (0.0) s1 s2;
          s1 : a b;
          s2 : c d;
          a : { seq = {seq, "a"}; };
          b : { seq = {seq, "b"}; };
          c : { seq = {seq, "c"}; };
          d : { seq = {seq, "d"}; };
        endsequence
      end
      default: begin
        randsequence (top1)
          top1 : rand join (1.0) s1 s2;
          s1 : a b;
          s2 : c d;
          a : { seq = {seq, "a"}; };
          b : { seq = {seq, "b"}; };
          c : { seq = {seq, "c"}; };
          d : { seq = {seq, "d"}; };
        endsequence
      end
    endcase
    if (seq == "abcd" || seq == "cdab") pure_count++;
  endtask

  initial begin
    foreach (orders[i]) orders[i] = 0;
    legal = 1;
    repeat (200) begin
      one("default", pure5);
      if (!legal_order(seq)) legal = 0;
      note(seq, orders);
    end
    distinct = 0;
    foreach (orders[i]) if (orders[i] > 0) distinct++;
    $display("rand join: legal orders %0d, more than two orders %0d",
             legal, distinct >= 3);
    pure0 = 0;
    repeat (600) begin
      one("0.0", pure0);
      if (!legal_order(seq)) pure0 = -1000;
    end
    pure1 = 0;
    repeat (600) begin
      one("1.0", pure1);
      if (!legal_order(seq)) pure1 = -1000;
    end
    pure5 = 0;
    repeat (600) one("default", pure5);
    $display("0.0 favors finished sequences over 1.0 %0d", pure0 > pure1);
    $display("default lies between 0.0 and 1.0 %0d",
             pure5 > pure1 && pure5 < pure0);
  end
endmodule

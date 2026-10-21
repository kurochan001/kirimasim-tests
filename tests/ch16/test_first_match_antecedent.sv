/*
:name: test_first_match_antecedent
:description: an implication whose antecedent has several matches checks the consequent after each of them, while first_match of the antecedent checks it only after the earliest; in a consequent, first_match keeps only the earliest match where the plain sequence may use a later one (IEEE 1800-2023 Section 16.9.8)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.8 16.12.7 16.12.2 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_first_match_antecedent.expected
*/
// IEEE 1800-2023 §16.9.8: first_match(s) has only the match of s that ends
// first (all of them if several end at that tick). §16.12.7: s |=> p needs p
// from the tick after every match of s, so a ##[1:3] b |=> c can fail after one
// match although c followed another. §16.12.2: a sequence used as a property
// holds if it has a match, so a |-> ##[1:3] b ##1 c holds if any b is followed
// by c, while first_match(##[1:3] b) ##1 c needs c after the first b. The fail
// actions (§16.14.1) record the failure times. a is high at 5, 55, 105, 155 and
// 205 only, and each attempt from there ends within four ticks. From 5: b at 15
// and 25, c at 25 only. From 55: b at 75, c at 85. From 105: b at 115 and 135,
// c at 125 only. From 155: no b. From 205: b at 215 and 235, c at 245 only.
// With Verilator 5.052 the first two assertions do not fail: for it, a
// consequent that holds after one match of the antecedent is enough, even after
// a match that first_match leaves out.

`timescale 1ns/1ns

module test_first_match_antecedent;
  logic clk = 0, a = 0, b = 0, c = 0;
  int f_all[$], f_first[$], f_cons_first[$], f_cons_all[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_all: assert property (@(posedge clk) a ##[1:3] b |=> c) else f_all.push_back($time);
  a_first: assert property (@(posedge clk) first_match(a ##[1:3] b) |=> c)
    else f_first.push_back($time);
  a_cons_first: assert property (@(posedge clk) a |-> first_match(##[1:3] b) ##1 c)
    else f_cons_first.push_back($time);
  a_cons_all: assert property (@(posedge clk) a |-> ##[1:3] b ##1 c)
    else f_cons_all.push_back($time);

  // Each signal is high for the ticks listed (tick n at 10 * n + 5).
  function automatic logic at(int n, int ticks[$]);
    foreach (ticks[i]) if (ticks[i] == n) return 1'b1;
    return 1'b0;
  endfunction

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    for (int n = 0; n < 27; n++) begin
      a = at(n, '{0, 5, 10, 15, 20});
      b = at(n, '{1, 2, 7, 11, 13, 21, 23});
      c = at(n, '{2, 8, 12, 24});
      #10;
    end
    $display("a ##[1:3] b |=> c failures:%s", times(f_all));
    $display("first_match(a ##[1:3] b) |=> c failures:%s", times(f_first));
    $display("a |-> first_match(##[1:3] b) ##1 c failures:%s", times(f_cons_first));
    $display("a |-> ##[1:3] b ##1 c failures:%s", times(f_cons_all));
    $finish;
  end
endmodule

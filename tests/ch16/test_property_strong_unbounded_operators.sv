/*
:name: test_property_strong_unbounded_operators
:description: nexttime[0] and s_nexttime[0] check the current tick, s_nexttime and s_nexttime[2] behave as their weak forms while the ticks exist, nexttime can take a sequence of two ticks, an unbounded always fails at the first tick its operand fails, and s_eventually and s_eventually[2:$] succeed at the first tick, from the start or from the second tick after it, where the operand holds (IEEE 1800-2023 Sections 16.12.10, 16.12.11, 16.12.13)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.10 16.12.11 16.12.13 16.12.15 16.12.9 16.14.3 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_strong_unbounded_operators.expected
*/
// IEEE 1800-2023 §16.12.10: nexttime[n] p and s_nexttime[n] p check p at the
// n-th next tick; with n = 0 they check it at the current tick. §16.12.15:
// a strong operator also needs the ticks to exist, which they do here, so
// the strong forms give the results of the weak ones. §16.12.11: always p needs
// p at every tick from the start on, so go |=> always h fails at the first
// tick after go without h. §16.12.13: s_eventually p holds at the first tick
// where p holds, and s_eventually [2:$] p at the first such tick at least two
// ticks after the start. The eventually properties are covered through
// start #-# (§16.12.9), so a cover property (§16.14.3) succeeds when they
// hold and nothing happens at the ticks without start. The fail actions
// (§16.14.1) and the covers record the times. go is high at 5 and 55: x is
// high at 5, 25 and 65, y at 25 and 75. start is high at 105 and 155: e at
// 115, 145, 155 and 205, and h from 115 to 135.

`timescale 1ns/1ns

module test_property_strong_unbounded_operators;
  logic clk = 0, go = 0, x = 0, y = 0, start = 0, e = 0, h = 0;
  int f_next0[$], f_snext0[$], f_snext[$], f_snext2[$], f_nextseq[$], f_always[$];
  int c_sev[$], c_sev2[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_next0: assert property (@(posedge clk) go |-> nexttime [0] x) else f_next0.push_back($time);
  a_snext0: assert property (@(posedge clk) go |-> s_nexttime [0] x)
    else f_snext0.push_back($time);
  a_snext: assert property (@(posedge clk) go |-> s_nexttime x) else f_snext.push_back($time);
  a_snext2: assert property (@(posedge clk) go |-> s_nexttime [2] x)
    else f_snext2.push_back($time);
  a_nextseq: assert property (@(posedge clk) go |-> nexttime (x ##1 y))
    else f_nextseq.push_back($time);
  a_always: assert property (@(posedge clk) start |=> always h) else f_always.push_back($time);
  cv_sev: cover property (@(posedge clk) start #-# s_eventually e) c_sev.push_back($time);
  cv_sev2: cover property (@(posedge clk) start #-# s_eventually [2:$] e)
    c_sev2.push_back($time);

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
    for (int n = 0; n < 23; n++) begin
      go = at(n, '{0, 5});
      x = at(n, '{0, 2, 6});
      y = at(n, '{2, 7});
      start = at(n, '{10, 15});
      e = at(n, '{11, 14, 15, 20});
      h = at(n, '{11, 12, 13});
      #10;
    end
    $display("go |-> nexttime [0] x failures:%s", times(f_next0));
    $display("go |-> s_nexttime [0] x failures:%s", times(f_snext0));
    $display("go |-> s_nexttime x failures:%s", times(f_snext));
    $display("go |-> s_nexttime [2] x failures:%s", times(f_snext2));
    $display("go |-> nexttime (x ##1 y) failures:%s", times(f_nextseq));
    $display("start |=> always h failures:%s", times(f_always));
    $display("start #-# s_eventually e covered:%s", times(c_sev));
    $display("start #-# s_eventually [2:$] e covered:%s", times(c_sev2));
    $finish;
  end
endmodule

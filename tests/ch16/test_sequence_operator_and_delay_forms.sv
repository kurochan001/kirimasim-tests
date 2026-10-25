/*
:name: test_sequence_operator_and_delay_forms
:description: Sequence and, or, intersect, within, throughout, first_match with a match item, the cycle delays ##n, ##[m:n], ##[m:$], ##[*] and ##[+], the repetitions [*n], [*m:n], [*], [+], [=n] and [->n], a leading delay, a chain, strong and weak, a parenthesized property, a property instance and a clocking event on a property each hold where their definitions say (IEEE 1800-2023 Sections 16.9, 16.12.2 and 16.12.15)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9 16.10 16.12.2 16.12.15 16.14.1 A.2.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_operator_and_delay_forms.expected
*/
// IEEE 1800-2023 §16.9 with A.2.10: a sequence expression is built from
// boolean expressions, sequence instances, parenthesized sequences with match
// items (§16.10), the operators and, or, intersect, within and throughout,
// first_match, and the cycle delays and repetitions of §16.9.2 and §16.9.3.
// A leading cycle delay is allowed, and a chain of delays joins several
// sequences. §16.12.2 makes a sequence used in an assert weak, and §16.12.15
// gives the explicit strong and weak forms, which agree when the sequence
// either matches or is already unable to match.
//
// Every assertion checks start |-> operator (§16.12.7), so one evaluation
// begins at the first tick of a phase. In the first phase only a is 1, at that
// tick, so every sequence that needs b or c at a later tick fails, while a
// parenthesized a, a[*1:3], a[+] and ##[*] a, which need no later tick, pass.
// In the second phase a, b, c and e are 1 at four ticks, so the same forms
// pass, except a__int_diff and a__win_rev, whose sequences cannot match with
// these ends, and every form that needs a later tick matches. The assertions
// with an unbounded delay or repetition are started only in the second phase
// (start2), where they match, so no attempt stays pending. The first_match
// match item counts its first match, one per phase.

`timescale 1ns/1ns

module test_sequence_operator_and_delay_forms;
  logic clk = 0, start = 0, start2 = 0, a = 0, b = 0, c = 0, e = 0;
  int fm = 0;
  int f_and = 0, f_or = 0, f_int = 0, f_int_diff = 0, f_win = 0, f_win_rev = 0;
  int f_thr = 0, f_fm = 0, f_cyc = 0, f_cyc0 = 0, f_cyc1 = 0;
  int f_rep2 = 0, f_rep13 = 0, f_rep_plus = 0, f_rep_eq = 0, f_rep_goto = 0;
  int f_chain = 0, f_dollar = 0, f_strong = 0, f_weak = 0;
  int f_paren = 0, f_prop = 0, f_delay1 = 0, f_range = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  property p_a;
    a;
  endproperty

  a_and: assert property (@(posedge clk) start |-> (a ##1 b) and (a ##2 c))
    else f_and++;
  a_or: assert property (@(posedge clk) start |-> (a ##1 b) or (a ##2 c))
    else f_or++;
  a_int: assert property (@(posedge clk) start |-> (a ##1 b) intersect (a ##1 c))
    else f_int++;
  a_int_diff: assert property (@(posedge clk) start |-> (a ##1 b) intersect (a ##2 c))
    else f_int_diff++;
  a_win: assert property (@(posedge clk) start |-> (a ##1 b) within (a ##2 c))
    else f_win++;
  a_win_rev: assert property (@(posedge clk) start |-> (a ##2 c) within (a ##1 b))
    else f_win_rev++;
  a_thr: assert property (@(posedge clk) start |-> e throughout (a ##2 c))
    else f_thr++;
  a_fm: assert property (@(posedge clk) start |-> first_match (a ##[1:2] b, fm = fm + 1))
    else f_fm++;
  a_cyc: assert property (@(posedge clk) start |-> ##[1:2] a) else f_cyc++;
  a_cyc0: assert property (@(posedge clk) start |-> ##[*] a) else f_cyc0++;
  a_cyc1: assert property (@(posedge clk) start2 |-> ##[+] a) else f_cyc1++;
  a_rep2: assert property (@(posedge clk) start |-> a[*2]) else f_rep2++;
  a_rep13: assert property (@(posedge clk) start |-> a[*1:3]) else f_rep13++;
  a_rep_plus: assert property (@(posedge clk) start |-> a[+]) else f_rep_plus++;
  a_rep_eq: assert property (@(posedge clk) start2 |-> a[=2]) else f_rep_eq++;
  a_rep_goto: assert property (@(posedge clk) start2 |-> a[->2]) else f_rep_goto++;
  a_chain: assert property (@(posedge clk) start |-> a ##1 b ##1 c) else f_chain++;
  a_dollar: assert property (@(posedge clk) start2 |-> a ##[1:$] b) else f_dollar++;
  a_strong: assert property (@(posedge clk) start |-> strong(a ##1 b)) else f_strong++;
  a_weak: assert property (@(posedge clk) start |-> weak(a ##1 b)) else f_weak++;
  a_paren: assert property (@(posedge clk) start |-> (a)) else f_paren++;
  a_prop: assert property (@(posedge clk) start |-> p_a and (@(posedge clk) a))
    else f_prop++;
  a_delay1: assert property (@(posedge clk) start |-> ##1 a) else f_delay1++;
  a_range: assert property (@(posedge clk) start |-> a ##[1:2] b) else f_range++;

  task automatic phase(bit all_high, bit with_start2);
    for (int i = 0; i < 4; i++) begin
      start = (i == 0);
      start2 = (i == 0) && with_start2;
      a = all_high || (!all_high && i == 0);
      b = all_high;
      c = all_high;
      e = all_high;
      #10;
    end
    start = 0;
    start2 = 0;
    a = 0;
    b = 0;
    c = 0;
    e = 0;
    #10;
    $display("all_high %0d: and %0d, or %0d, intersect %0d, intersect_diff %0d", all_high,
             f_and, f_or, f_int, f_int_diff);
    $display("  within %0d, within_rev %0d, throughout %0d, first_match %0d (fm %0d)", f_win,
             f_win_rev, f_thr, f_fm, fm);
    $display("  cyc %0d, cyc_star %0d, cyc_plus %0d, rep2 %0d, rep13 %0d, rep_plus %0d",
             f_cyc, f_cyc0, f_cyc1, f_rep2, f_rep13, f_rep_plus);
    $display("  rep_eq %0d, rep_goto %0d, chain %0d, dollar %0d", f_rep_eq, f_rep_goto,
             f_chain, f_dollar);
    $display("  strong %0d, weak %0d, paren %0d, prop %0d, delay1 %0d, range %0d", f_strong,
             f_weak, f_paren, f_prop, f_delay1, f_range);
    f_and = 0;
    f_or = 0;
    f_int = 0;
    f_int_diff = 0;
    f_win = 0;
    f_win_rev = 0;
    f_thr = 0;
    f_fm = 0;
    f_cyc = 0;
    f_cyc0 = 0;
    f_cyc1 = 0;
    f_rep2 = 0;
    f_rep13 = 0;
    f_rep_plus = 0;
    f_rep_eq = 0;
    f_rep_goto = 0;
    f_chain = 0;
    f_dollar = 0;
    f_strong = 0;
    f_weak = 0;
    f_paren = 0;
    f_prop = 0;
    f_delay1 = 0;
    f_range = 0;
    fm = 0;
  endtask

  initial begin
    phase(0, 0);
    phase(1, 1);
    $finish;
  end
endmodule

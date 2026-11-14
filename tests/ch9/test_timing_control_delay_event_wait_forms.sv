/*
:name: test_timing_control_delay_event_wait_forms
:description: each delay control form, @ with an identifier, a hierarchical identifier or a parenthesized expression, edge and value-change expressions, or, comma and parenthesized event expressions, @* and @(*), delay and event controls inside assignments, wait with a statement or a null statement, and wait fork each resume at the time the stimulus fixes (IEEE 1800-2023 Section 9.4)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_control_delay_event_wait_forms.expected
*/
// IEEE 1800-2023 §9.4 (Syntax 9-4): a procedural timing control is followed
// by a statement or the null statement. A delay control is # with a delay
// value (a number, an identifier or a time literal) or # with a
// parenthesized expression. An event control is @ with an identifier or a
// hierarchical identifier, @ with a parenthesized event expression, @* or
// @(*). An event expression is an expression with an optional posedge,
// negedge or edge, or two event expressions joined with or or a comma, or
// one in parentheses. A delay or event control can be written inside an
// assignment. wait takes an expression and a statement or the null
// statement, and wait fork waits for the processes the fork started. The
// package-scoped identifier, the repeat count, iff, the sequence event, the
// cycle delay and wait_order are in
// test_timing_control_iff_sequence_cycle_wait_order_forms.
//
// The stimulus process triggers ev1 at 5 and the event of u_sub at 10,
// raises clk at 20, lowers it at 25, raises a at 30, sets v to 3 at 35,
// triggers ev2 at 40 and raises b at 45. Each other process waits with one
// form and stores the time at which it resumes; the last process prints them
// in a fixed order, so the output does not depend on the order of processes
// that resume together.
// - #P with the parameter P = 2, #3 with an assignment, #(D + 1) with D = 3
//   and #6ns resume at 2, 3, 4 and 6.
// - @ev1, @(ev1) and @ u_sub.sub_ev resume at 5, 5 and 10.
// - posedge clk, negedge clk, edge a and a change of v resume at 20, 25, 30
//   and 35.
// - (ev2 or ev1), (ev2, ev1) and ((ev2) or (ev1)) resume first at 5 on ev1,
//   then at 40 on ev2.
// - always @* and always @(*) follow a + b after the changes of a and b
//   (2 and 12 at the end).
// - r = #7 v takes v at time 0 (9) and completes at 7; s <= @(ev2) v is
//   still 0 at 39 and 9 after ev2.
// - wait (v == 3) with the null statement resumes at 35, and wait (b) with an
//   assignment at 45. wait fork resumes when the longer of two processes
//   started by fork-join_none ends, at 17.
// A tool that read a form as another one, or resumed a wrong process, would
// print another time or value on that line.

`timescale 1ns/1ns

module tc_sub;
  event sub_ev;
endmodule

module test_timing_control_delay_event_wait_forms;
  parameter int P = 2;
  int D = 3;
  logic clk = 0, a = 0, b = 0;
  logic [3:0] v = 4'd9;
  event ev1, ev2;
  int t_p, t_num, t_expr, t_lit, t_id, t_paren_id, t_hier;
  int t_pos, t_neg, t_edge, t_change;
  int t_or[2], t_comma[2], t_nested[2];
  int star = -1, paren_star = -1;
  int t_intra_delay, t_wait_null, t_wait_stmt, t_wait_fork;
  int x_num, r, s, s_at_39, w_flag;

  tc_sub u_sub();

  initial begin
    #5 ->ev1;
    #5 ->u_sub.sub_ev;
    #10 clk = 1;
    #5 clk = 0;
    #5 a = 1;
    #5 v = 4'd3;
    #5 ->ev2;
    #5 b = 1;
  end

  initial begin #P; t_p = $time; end
  initial begin #3 x_num = 1; t_num = $time; end
  initial begin #(D + 1); t_expr = $time; end
  initial begin #6ns; t_lit = $time; end

  initial begin @ev1; t_id = $time; end
  initial begin @(ev1); t_paren_id = $time; end
  initial begin @ u_sub.sub_ev; t_hier = $time; end

  initial begin @(posedge clk); t_pos = $time; end
  initial begin @(negedge clk); t_neg = $time; end
  initial begin @(edge a); t_edge = $time; end
  initial begin @(v); t_change = $time; end

  initial begin
    @(ev2 or ev1) t_or[0] = $time;
    @(ev2 or ev1) t_or[1] = $time;
  end
  initial begin
    @(ev2, ev1) t_comma[0] = $time;
    @(ev2, ev1) t_comma[1] = $time;
  end
  initial begin
    @((ev2) or (ev1)) t_nested[0] = $time;
    @((ev2) or (ev1)) t_nested[1] = $time;
  end

  always @* star = a + b;
  always @(*) paren_star = a + b + 10;

  initial begin
    r = #7 v;
    t_intra_delay = $time;
  end
  initial begin
    s <= @(ev2) v;
    #39 s_at_39 = s;
  end

  initial begin wait (v == 4'd3); t_wait_null = $time; end
  initial begin wait (b) w_flag = 1; t_wait_stmt = $time; end
  initial begin
    fork
      #12;
      #17;
    join_none
    wait fork;
    t_wait_fork = $time;
  end

  initial begin
    #60;
    $display("delay: #P %0d, #3 %0d (x=%0d), #(D + 1) %0d, #6ns %0d",
             t_p, t_num, x_num, t_expr, t_lit);
    $display("named events: @ev1 %0d, @(ev1) %0d, hierarchical %0d",
             t_id, t_paren_id, t_hier);
    $display("edges: posedge %0d, negedge %0d, edge %0d, change %0d",
             t_pos, t_neg, t_edge, t_change);
    $display("or %0d %0d, comma %0d %0d, parenthesized %0d %0d",
             t_or[0], t_or[1], t_comma[0], t_comma[1], t_nested[0], t_nested[1]);
    $display("@* %0d, @(*) %0d", star, paren_star);
    $display("#7 inside: r=%0d at %0d; @(ev2) inside: s=%0d then %0d",
             r, t_intra_delay, s_at_39, s);
    $display("wait null %0d, wait statement %0d (flag=%0d), wait fork %0d",
             t_wait_null, t_wait_stmt, w_flag, t_wait_fork);
  end
endmodule

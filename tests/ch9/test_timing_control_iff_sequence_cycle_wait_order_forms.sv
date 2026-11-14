/*
:name: test_timing_control_iff_sequence_cycle_wait_order_forms
:description: @ with a package-scoped identifier, repeat event controls inside blocking and nonblocking assignments, iff after an edge and after a sequence instance, a sequence instance as an event, cycle delays with a null statement and with a statement, and wait_order with its pass and fail statements each resume at the time the stimulus fixes (IEEE 1800-2023 Section 9.4)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_control_iff_sequence_cycle_wait_order_forms.expected
*/
// IEEE 1800-2023 §9.4 (Syntax 9-4) also allows these timing control forms:
// @ with a package-scoped identifier; a repeat count before the event
// control of an assignment; iff after an event expression with an edge and
// after a sequence instance; a sequence instance as an event expression; a
// cycle delay as a procedural timing control, followed by a statement or the
// null statement; and wait_order with an action block. The other forms of
// Syntax 9-4 are in test_timing_control_delay_event_wait_forms.
//
// clk rises at 5, 15, 25, ... and falls at 10, 20, .... The other changes
// fall between rising edges: v from 9 to 3 at 8, the package event at 12, en
// and en2 to 1 at 22 and 50, a and b to 1 at 30 and 40, e1, e2, e3 at 60,
// 62, 64, and f2 before f1 at 70 and 72. Each waiting process stores the
// time at which it resumes, and the last process prints them in a fixed
// order.
// - @ tc_iff_pkg::pkg_ev resumes at 12.
// - q = repeat (2) @(posedge clk) v takes v at time 0 (9) and completes at the
//   second rising edge, 15. q2 <= repeat (cnt) @(negedge clk) v with cnt = 3
//   takes 9 at time 0 and updates q2 at the third falling edge, 30: q2 is 0
//   at 29, then 9.
// - @(posedge clk iff en) skips the edges at 5 and 15, where en is 0, and
//   resumes at 25.
// - The sequence s_ab (a, then b one clock later) first reaches its end point
//   at 45, where @(s_ab) resumes (§9.4.2.4); @(s_ab iff en2) skips that end
//   point, since en2 is 0 at 45, and resumes at the next one, 55.
// - With the default clocking on the rising edge of clk (§14.11), ##2 from
//   time 0 resumes at 15, ##1 with an assignment at 25, ##(k + 1) with k = 0
//   at 35.
// - wait_order (e1, e2, e3) sees the events in order and runs its pass
//   statement at 64; wait_order (f1, f2) sees f2 first and runs its else
//   statement at 70 (§15.5.4).
// A tool that read a form as another one, or resumed at another time, would
// print another time or value on that line.
//
// Icarus Verilog 13.0 does not accept the default clocking declaration (a
// syntax error). The 5.054 release of Verilator does not support the repeat
// event control or wait_order; with those two forms replaced by equivalent
// statements it prints the other lines of this output. The expected output
// follows the standard.

`timescale 1ns/1ns

package tc_iff_pkg;
  event pkg_ev;
  task fire();
    ->pkg_ev;
  endtask
endpackage

module test_timing_control_iff_sequence_cycle_wait_order_forms;
  logic clk = 0, en = 0, en2 = 0, a = 0, b = 0;
  logic [3:0] v = 4'd9;
  int k = 0, cnt = 3;
  event e1, e2, e3, f1, f2;
  int t_pkg, t_rep, t_iff, t_seq, t_seq_iff, t_cyc2, t_cyc1, t_cyc_expr, t_pass, t_fail;
  int q, q2, q2_at_29, c_flag, order_pass, order_fail, f_pass, f_fail;

  default clocking cb @(posedge clk);
  endclocking

  sequence s_ab;
    @(posedge clk) a ##1 b;
  endsequence

  always #5 clk = ~clk;

  initial begin
    #8 v = 4'd3;
    #4 tc_iff_pkg::fire();
    #10 en = 1;
    #8 a = 1;
    #10 b = 1;
    #10 en2 = 1;
    #10 ->e1;
    #2 ->e2;
    #2 ->e3;
    #6 ->f2;
    #2 ->f1;
  end

  initial begin @ tc_iff_pkg::pkg_ev; t_pkg = $time; end

  initial begin
    q = repeat (2) @(posedge clk) v;
    t_rep = $time;
  end
  initial begin
    q2 <= repeat (cnt) @(negedge clk) v;
    #29 q2_at_29 = q2;
  end

  initial begin @(posedge clk iff en); t_iff = $time; end

  initial begin @(s_ab) t_seq = $time; end
  initial begin @(s_ab iff en2) t_seq_iff = $time; end

  initial begin
    ##2;
    t_cyc2 = $time;
    ##1 c_flag = 1;
    t_cyc1 = $time;
    ##(k + 1);
    t_cyc_expr = $time;
  end

  initial begin
    wait_order (e1, e2, e3) order_pass = 1; else order_fail = 1;
    t_pass = $time;
  end
  initial begin
    wait_order (f1, f2) f_pass = 1; else f_fail = 1;
    t_fail = $time;
  end

  initial begin
    #100;
    $display("package-scoped event: %0d", t_pkg);
    $display("repeat: q=%0d at %0d; q2=%0d at 29, then %0d", q, t_rep, q2_at_29, q2);
    $display("posedge clk iff en: %0d", t_iff);
    $display("sequence: %0d, sequence iff en2: %0d", t_seq, t_seq_iff);
    $display("cycle delays: ##2 %0d, ##1 %0d (flag=%0d), ##(k + 1) %0d",
             t_cyc2, t_cyc1, c_flag, t_cyc_expr);
    $display("wait_order in order: pass=%0d fail=%0d at %0d", order_pass, order_fail, t_pass);
    $display("wait_order out of order: pass=%0d fail=%0d at %0d", f_pass, f_fail, t_fail);
    $finish;
  end
endmodule

/*
:name: test_procedural_assertion_flush_points
:description: a pending procedural concurrent assertion is flushed when its process resumes from an event control in the same time step, but not when it resumes from a #0 delay; an instance requeued after a change made in the Reactive region is evaluated too, after the first one has already failed (IEEE 1800-2023 Sections 16.14.6.2, 16.14.6.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.6.2 16.14.6.3 16.14.6 16.14.6.1 24.3 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_procedural_assertion_flush_points.expected
*/
// IEEE 1800-2023 §16.14.6: a concurrent assertion reached in procedural code is
// queued with the current values of its const casts (§16.14.6.1) and matures in
// the Observed region; it is evaluated then if its clock ticked in that time
// step, else at its next tick. §16.14.6.2: the queue of a process is flushed
// when the process resumes after waiting at an event control or wait statement;
// a delay control is not such a point. At 12, lo becomes 5 and then, after #0,
// hi 7: p_pair runs twice and only the instance with hi >= lo matures; at 32 lo
// becomes 9 alone, so c_order fails at 35. a_zero and a_ev are queued at 22
// with k and k2 still 0: a_zero survives the #0 after it and fails at 25, a_ev
// is flushed when @ev resumes its process. §16.14.6.3: a change in the Reactive
// region can still make an assertion report a glitch. p_total keeps total =
// base + extra and checks that it is 10. At the clock edge at 75, base goes
// from 3 to 4, and the instance queued with total 11 matures and fails in the
// Observed region; the program (§24.3) then sets extra to 6 in the Reactive
// region, p_total runs again, and the new instance passes in the same time
// step. k_sum also passes at 5, from the instance queued when p_total ran at
// time 0. The action blocks (§16.14.1) record the times.

`timescale 1ns/1ns

module test_procedural_assertion_flush_points;
  logic clk = 0;
  int lo = 0, hi = 0, k = 0, k2 = 0, base = 3, extra = 7, total;
  event ev;
  int f_order[$], f_zero[$], f_ev[$], p_sum[$], f_sum[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  always @(lo, hi) begin : p_pair
    c_order: assert property (@(posedge clk) const'(hi) >= const'(lo))
      else f_order.push_back($time);
  end

  initial begin : p_delay
    #22;
    a_zero: assert property (@(posedge clk) const'(k) == 1) else f_zero.push_back($time);
    #0;
    k = 1;
  end

  initial begin : p_event
    #22;
    a_ev: assert property (@(posedge clk) const'(k2) == 1) else f_ev.push_back($time);
    @ev;
    k2 = 1;
  end

  initial begin
    #22;
    #0;
    ->ev;
  end

  always_comb begin : p_total
    total = base + extra;
    k_sum: assert property (@(posedge clk) const'(total) == 10) p_sum.push_back($time);
      else f_sum.push_back($time);
  end

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    #12 lo = 5;
    #0 hi = 7;
    #20 lo = 9;
    #43 base = 4;   // 75, with the clock edge
    #25;
    $display("c_order failures:%s", times(f_order));
    $display("a_zero failures:%s", times(f_zero));
    $display("a_ev failures:%s", times(f_ev));
    $display("k_sum passes:%s, failures:%s", times(p_sum), times(f_sum));
    $finish;
  end
endmodule

// Brings total back to 10 in the Reactive region at 75.
program fix_extra;
  initial begin
    #75 test_procedural_assertion_flush_points.extra =
        10 - test_procedural_assertion_flush_points.base;
    #50;
  end
endprogram

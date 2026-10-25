/*
:name: test_procedural_assertion_queue_rules
:description: the if around a procedural concurrent assertion uses current values unless it calls $sampled; a matured instance completes whatever its procedure does afterwards, with the automatic values it was queued with; resuming after a wait and an always_comb or always_latch resuming on a change flush the queue, a delay does not, and disabling a task does not (IEEE 1800-2023 Section 16.14.6.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.6.1 16.14.6.2 16.14.6.4 16.14.6 9.2.2.2 9.4.3 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_procedural_assertion_queue_rules.expected
*/
// IEEE 1800-2023 §16.14.6.1: the conditions of the procedural code around a
// concurrent assertion use current values, the assertion sampled ones, so
// if (en) queues a9 at the tick where en is assigned 1 (25) and
// if ($sampled(en)) queues a10 one tick later (35). Once an instance has
// matured, the later execution of its procedure no longer affects it, and
// the automatic values it was queued with stay fixed for its whole attempt:
// a7 is queued at 55 for i = 0 and 1 only; the instance for i = 1 fails at 65
// on bar[1], the one for i = 0 passes at 75 on w, while the procedure keeps
// running with act low. §16.14.6.2: a process that resumes after a wait
// statement (§9.4.3), and an always_comb or always_latch (§9.2.2.2) that
// resumes on a change of a signal it depends on, reach a flush point, which
// clears its pending instances; a delay is not one (§16.14.6). a_w is queued
// at 82 and flushed when its process resumes from wait in the same time step;
// a_w2 survives a #0 and fails at 85. At 92 x1 and y1 change and, after #0, x2
// and y2: the instances of a_c and a_l queued with a mismatch are flushed
// when their procedures run again; at 102 and 103 the same changes are one
// time unit apart, so the instance queued at 102 matures and fails at 105.
// §16.14.6.4: disabling a task does not flush the queue of the process that
// called it: a_t, queued at 112 before the call, fails at 115; disabling the
// outermost scope of a process does flush it, besides ending the process as
// usual: a_d1 and a_d2, queued at 122 when p_out is disabled, never fail, and
// p_out does not reach the assignment after its delay. The action
// blocks (§16.14.1) record the times. Icarus Verilog 13.0 does not support
// these assertions. The 5.052 release of Verilator rejects the ##1 in a7,
// asking for a default clocking, as it does not infer the clock of a7 from
// its always procedure.

`timescale 1ns/1ns

module test_procedural_assertion_queue_rules;
  logic clk = 0, e_in = 0, en = 0, act = 0, w = 0, go_w = 0;
  logic [1:0] foo = 0, bar = 0;
  logic x1 = 0, x2 = 0, y1 = 0, y2 = 0, eq_c, eq_l;
  int kw = 0, kw2 = 0;
  event ev_t, ev_d;
  bit after_d = 0;
  int f9[$], f10[$], fw[$], fw2[$], fc[$], fl[$], ft[$], fd1[$], fd2[$];
  string p7[$], f7[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  always @(posedge clk) begin
    en = e_in;
    if (en) a9: assert property (1'b0) else f9.push_back($time);
    if ($sampled(en)) a10: assert property (1'b0) else f10.push_back($time);
  end

  always @(posedge clk) begin
    if (act)
      for (int i = 0; i < 2; i++)
        a7: assert property (foo[i] |=> bar[i] ##1 w) p7.push_back($sformatf("%0d (i=%0d)",
                                                                   $time, i));
          else f7.push_back($sformatf("%0d (i=%0d)", $time, i));
  end

  initial begin : p_wait
    #82;
    a_w: assert property (@(posedge clk) const'(kw) == 1) else fw.push_back($time);
    wait (go_w);
    kw = 1;
  end

  initial begin : p_delay
    #82;
    a_w2: assert property (@(posedge clk) const'(kw2) == 1) else fw2.push_back($time);
    #0;
    kw2 = 1;
  end

  always_comb begin : p_comb
    eq_c = (x1 == x2);
    a_c: assert property (@(posedge clk) const'(x1) == const'(x2)) else fc.push_back($time);
  end

  always_latch begin : p_latch
    eq_l = (y1 == y2);
    a_l: assert property (@(posedge clk) const'(y1) == const'(y2)) else fl.push_back($time);
  end

  task tsk;
    #20;
  endtask

  always @(ev_t) begin : p_task
    a_t: assert property (@(posedge clk) 1'b0) else ft.push_back($time);
    tsk();
  end

  always @(ev_d) begin : p_out
    a_d1: assert property (@(posedge clk) 1'b0) else fd1.push_back($time);
    a_d2: assert property (@(posedge clk) 1'b0) else fd2.push_back($time);
    #20;
    after_d = 1;
  end

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  function automatic string strs(string q[$]);
    string s = "";
    foreach (q[i]) s = {s, " ", q[i]};
    return s;
  endfunction

  initial begin
    #20 e_in = 1;              // sampled at 25
    #10 e_in = 0;
    #20 act = 1; foo = 2'b11;  // 50, for the tick at 55
    #10 act = 0; foo = 0; bar = 2'b01;
    #10 bar = 0; w = 1;
    #10 w = 0;                 // 80
    #2;                        // 82
    #0 go_w = 1;
    #10 x1 = 1; y1 = 1;        // 92
    #0 x2 = 1; y2 = 1;
    #10 x1 = 0; y1 = 0;        // 102
    #1 x2 = 0; y2 = 0;         // 103
    #9 ->ev_t;                 // 112
    #0 disable tsk;
    #10 ->ev_d;                // 122
    #0 disable p_out;
    #18;
    $display("a9 (if (en)) failures at%s", times(f9));
    $display("a10 (if ($sampled(en))) failures at%s", times(f10));
    $display("a7 passes at%s; failures at%s", strs(p7), strs(f7));
    $display("a_w (resumed from wait) failures at%s", times(fw));
    $display("a_w2 (after #0) failures at%s", times(fw2));
    $display("a_c (always_comb) failures at%s", times(fc));
    $display("a_l (always_latch) failures at%s", times(fl));
    $display("a_t (task disabled) failures at%s", times(ft));
    $display("a_d1, a_d2 (p_out disabled) failures at%s%s; after_d %0d", times(fd1), times(fd2),
             after_d);
    $finish;
  end
endmodule

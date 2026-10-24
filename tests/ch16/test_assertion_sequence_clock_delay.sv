/*
:name: test_assertion_sequence_clock_delay
:description: a sequence can be the clocking event of a concurrent assertion; a sequence that needs no sampled value ticks in the time step of its clock edge, like the edge itself, while a sequence whose match depends on the sampled value of a signal ticks only at a later tick of its own clock, where that sampled value is seen (IEEE 1800-2023 Section 16.5.2)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.5.2 9.4.2.4 16.5.1 16.14.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertion_sequence_clock_delay.expected
*/
// IEEE 1800-2023 §16.5.2: as in an event control (§9.4.2.4), a sequence can
// be the clocking event of an assertion, which then ticks where a match of
// the sequence ends. An edge of an ordinary clock in the Active region makes
// the assertion evaluate in the same time step; for a sequence clock this
// holds only when its match does not depend on sampled values (§16.5.1).
// fast rises at 10, 20, ..., 100; slow rises at 30 and 70 and falls at 50.
// s_edge, @(posedge slow) 1'b1, matches at 30 and 70 like posedge slow.
// s_late, @(posedge fast) !slow ##1 slow, needs slow sampled as 1, which
// happens at the fast ticks at 40 and 80 only, one tick of fast after each
// rise. cond is sampled as 1 at 30 and 80 and as 0 at 40 and 70. So the
// assertions clocked by posedge slow and by s_edge pass at 30 and fail at
// 70, while the one clocked by s_late fails at 40 and passes at 80. The
// action blocks (§16.14.1) record the times.

`timescale 1ns/1ns

module test_assertion_sequence_clock_delay;
  logic fast = 0, slow = 0, cond = 0;
  int p_slow[$], f_slow[$], p_edge[$], f_edge[$], p_late[$], f_late[$];

  sequence s_edge;
    @(posedge slow) 1'b1;
  endsequence

  sequence s_late;
    @(posedge fast) !slow ##1 slow;
  endsequence

  a_slow: assert property (@(posedge slow) cond) p_slow.push_back($time);
    else f_slow.push_back($time);
  a_edge: assert property (@(s_edge) cond) p_edge.push_back($time);
    else f_edge.push_back($time);
  a_late: assert property (@(s_late) cond) p_late.push_back($time);
    else f_late.push_back($time);

  initial forever begin   // rising edges at 10, 20, ...
    #5 fast = 0;
    #5 fast = 1;
  end

  function automatic string times(int t[$]);
    string str = "";
    foreach (t[i]) str = {str, $sformatf(" %0d", t[i])};
    return str;
  endfunction

  initial begin
    #25 cond = 1;   // sampled as 1 at 30
    #10 cond = 0;   // 35
    #40 cond = 1;   // 75, sampled as 1 at 80
    #10 cond = 0;   // 85
  end

  initial begin
    #30 slow = 1;
    #20 slow = 0;   // 50
    #20 slow = 1;   // 70
    #40;            // 110
    $display("@(posedge slow): passes%s, failures%s", times(p_slow), times(f_slow));
    $display("@(s_edge): passes%s, failures%s", times(p_edge), times(f_edge));
    $display("@(s_late): passes%s, failures%s", times(p_late), times(f_late));
    $finish;
  end
endmodule

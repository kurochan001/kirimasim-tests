/*
:name: test_deferred_assertion_flush
:description: a deferred assertion queues its report instead of acting at once; when its process is resumed again in the same time step, or its outermost scope is disabled, the queue is flushed, so only the last result is reported; a deferred assertion outside procedures acts as in an always_comb, and final deferred assertions also ignore results replaced by the reactive region (IEEE 1800-2023 Sections 16.4, 16.4.1 to 16.4.4)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.4 16.4.1 16.4.2 16.4.3 16.4.4 16.3 24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_deferred_assertion_flush.expected
*/
// IEEE 1800-2023 §16.4.1: a deferred assertion puts its report on the queue
// of its process; the report matures in the Observed region (#0) or the
// Postponed region (final) and its action then runs. §16.4.2: an always_comb
// resumed by a change of an input flushes the queue. When x changes, y
// follows through a nonblocking assignment, so the always_comb first sees x
// != y and then, after the NBA region, x == y: the simple immediate assertion
// (§16.3) fails once, the deferred one only passes. §16.4.3: a deferred
// assertion outside procedures behaves as in an always_comb. §16.4.4:
// disabling the outermost scope of a procedure flushes its queue. At 20 the
// module sets w and a program (§24.3) then sets z in the Reactive region: the
// observed deferred assertion reports the failure and then the pass, the
// final one only the pass. The action blocks are single calls of count; the
// counts of time 0 are cleared at 1, and only nonzero counts are printed.

`timescale 1ns/1ns

module test_deferred_assertion_flush;
  logic x = 0, y = 0, go = 0, cancel = 0, w = 0, z = 0;
  int n[string];

  function automatic void count(string what);
    n[what]++;
  endfunction

  always @(x) y <= x;

  always_comb begin
    a_imm: assert (x == y) else count("immediate fail");
    a_def: assert #0 (x == y) count("deferred pass"); else count("deferred fail");
  end

  a_static: assert #0 (x == y) else count("static fail");

  always @(go) begin : b_dis
    a_dis: assert #0 (1'b0) else count("disable fail");
    if (cancel) disable b_dis;
  end

  a_obs: assert #0 (!(w && !z)) count("observed pass"); else count("observed fail");
  a_fin: assert final (!(w && !z)) count("final pass"); else count("final fail");

  initial begin
    #1 n.delete();
    #4 x = 1;
    #5 go = 1;          // 10: reported
    #2 cancel = 1;
    go = 0;             // 12: flushed by the disable
    #8 w = 1;           // 20
    #10;
    foreach (n[what]) $display("%s: %0d", what, n[what]);
  end
endmodule

// Sets z in the Reactive region at 20; it ends at 40, which ends the
// simulation (§24.3).
program set_z;
  initial begin
    #20 test_deferred_assertion_flush.z = 1;
    #20;
  end
endprogram

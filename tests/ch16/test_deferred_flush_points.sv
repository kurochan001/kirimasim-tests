/*
:name: test_deferred_flush_points
:description: resuming an always_comb or always_latch after a sensitivity change and resuming a process from an event control are deferred assertion flush points, disabling the outermost scope of a procedure flushes its pending reports, and disabling a non-outermost scope does not (IEEE 1800-2023 Sections 16.4.2 and 16.4.4)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.4.2 16.4.4 16.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_deferred_flush_points.expected
*/
// IEEE 1800-2023 §16.4.2: a process reaches a deferred assertion flush point
// when it resumes after an event control or wait, and also when an always_comb
// or always_latch resumes because a signal it depends on changed. §16.4.4: a
// disable of the outermost scope of a procedure flushes its whole pending
// report queue, but a disable of a non-outermost scope does not. §16.4.1: a
// pending report that is not flushed matures in the Observed region and runs
// its action in the Reactive region of the time step.
// The always_comb block evaluates its assertion before the continuous
// assignment settles nca, so the first evaluation fails and is flushed when
// nca changes; only the settled pass is reported at 5. The always_latch block
// evaluates before it updates lq, so the change of ld at 15 first queues a
// failure, which the update of lq flushes; only the pass is reported. The
// event-controlled block queues a failure when ea changes at 25 and is
// resumed by eb at #0 in the same time step, which flushes it, so only the
// pass is reported. The outer_a procedure is disabled after it queues a
// failure at 35, so nothing is reported; outer_b is not disabled, so its
// failure is reported at 45; disabling only inner_c leaves the pending
// failure of outer_c to mature at 55.

`timescale 1ns/1ns

module test_deferred_flush_points;
  logic ca = 0;
  logic nca;
  logic en = 0, ld = 0, lq = 0;
  logic ea = 1, eb = 1;
  logic da = 0, db = 0, dc = 0;

  assign nca = ~ca;

  task automatic note(string s);
    if ($time != 0) $display("%s", s);
  endtask

  always_comb begin : comb_blk
    a0: assert #0 (!(ca && nca))
      note($sformatf("t=%0t comb pass", $time));
      else note($sformatf("t=%0t comb fail", $time));
  end

  always_latch begin : latch_blk
    a1: assert #0 (lq == ld || !en)
      note($sformatf("t=%0t latch pass", $time));
      else note($sformatf("t=%0t latch fail", $time));
    if (en) lq = ld;
  end

  always @(ea or eb) begin : event_blk
    a2: assert #0 (ea == eb)
      note($sformatf("t=%0t event pass", $time));
      else note($sformatf("t=%0t event fail", $time));
  end

  always @(da) begin : outer_a
    a3: assert #0 (da == 0)
      note($sformatf("t=%0t outer_a pass", $time));
      else note($sformatf("t=%0t outer_a fail", $time));
  end

  always @(db) begin : outer_b
    a4: assert #0 (db == 0)
      note($sformatf("t=%0t outer_b pass", $time));
      else note($sformatf("t=%0t outer_b fail", $time));
  end

  always @(dc) begin : outer_c
    a5: assert #0 (dc == 0)
      note($sformatf("t=%0t outer_c pass", $time));
      else note($sformatf("t=%0t outer_c fail", $time));
    begin : inner_c
      #0 disable inner_c;
    end
  end

  initial begin
    #5 ca = 1;
    #5 en = 1;
    #5 ld = 1;
    #10 ea = 0;
    #0 eb = 0;
    #10 da = 1;
    #0 disable outer_a;
    #10 db = 1;
    #10 dc = 1;
    #5 $finish;
  end
endmodule

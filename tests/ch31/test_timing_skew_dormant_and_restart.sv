/*
:name: test_timing_skew_dormant_and_restart
:description: $skew never reports a missing data event while timer-based $timeskew does; event-based $timeskew turns dormant after its first violation or a reference event whose condition is false; and in both modes of $fullskew a second timestamp event replaces the window, while one whose condition is false is ignored with the remain_active_flag and makes the check dormant without it (IEEE 1800-2023 Section 31.4.2)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.4.2 31.4.3 31.4.1 31.4 31.7 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_skew_dormant_and_restart.expected
*/
// IEEE 1800-2023 §31.4.1: $skew is evaluated only at data events, so without
// a data event it never reports; timer-based $timeskew and $fullskew report
// when the limit has passed. §31.4.2: with only the event_based_flag,
// $timeskew behaves like $skew except that it turns dormant after its first
// violation, or at a conditioned reference event whose condition is false,
// until the next reference event. §31.4.3: in timer-based and in event-based
// mode, a second timestamp event before the window has ended starts a new
// window that replaces the first; if its condition is false, the check
// ignores it when the remain_active_flag is set and otherwise turns dormant.
// A dormant check is activated again by a timestamp event. §31.7: a reference
// event is detected only while its condition is true. §31.6: each violation
// toggles the notifier, which starts at 0. All events are rising edges.
//   r6 at 10, no d6: $skew none; $timeskew (limit 5) 15.
//   m7 = 1, r7 at 10, d7 at 17 and 19: $skew (limit 5) 17 and 19, event-based
//   $timeskew only 17. r7 at 30, r7 at 33 with m7 = 0, d7 at 40: $skew takes
//   40 - 30 > 5 and reports 40; $timeskew is dormant after 33 and does not.
//   $fullskew (posedge r8 &&& m8, posedge d8, 5, 8), in four variants:
//   r8 at 10 and 13, d8 at 17: the window of 13 replaces that of 10, so d8 is
//   in time and no variant reports (15 for timer-based, 17 for event-based
//   if 10 were kept). r8 at 30, r8 at 33 with m8 = 0, d8 at 37, r8 at 40: with
//   the flag, 33 is ignored, so the window of 30 ends late: timer-based 35,
//   event-based 37; without it the check is dormant at 33, d8 at 37 starts a
//   window from d8 that r8 at 40 closes in time, and nothing is reported.
// The times at which each notifier changes are printed at the end.
//
// Icarus Verilog 13.0 skips timing checks, so the notifiers never change.

`timescale 1ns/1ns

module tsd_checks (input r6, d6, r7, d7, m7, r8, d8, m8);
  reg nf = 0, ng = 0, nh = 0, ni = 0, nj = 0, nk = 0, nl = 0, nm = 0;
  specify
    $skew(posedge r6, posedge d6, 5, nf);
    $timeskew(posedge r6, posedge d6, 5, ng);
    $timeskew(posedge r7 &&& m7, posedge d7, 5, nh, 1);
    $skew(posedge r7 &&& m7, posedge d7, 5, ni);
    $fullskew(posedge r8 &&& m8, posedge d8, 5, 8, nj);
    $fullskew(posedge r8 &&& m8, posedge d8, 5, 8, nk, 0, 1);
    $fullskew(posedge r8 &&& m8, posedge d8, 5, 8, nl, 1);
    $fullskew(posedge r8 &&& m8, posedge d8, 5, 8, nm, 1, 1);
  endspecify
endmodule

module test_timing_skew_dormant_and_restart;
  reg r6 = 0, d6 = 0, r7 = 0, d7 = 0, m7 = 1, r8 = 0, d8 = 0, m8 = 1;
  string lf = "", lg = "", lh = "", li = "", lj = "", lk = "", ll = "", lm = "";

  tsd_checks u (r6, d6, r7, d7, m7, r8, d8, m8);

  always @(u.nf) lf = {lf, $sformatf(" %0d", $time)};
  always @(u.ng) lg = {lg, $sformatf(" %0d", $time)};
  always @(u.nh) lh = {lh, $sformatf(" %0d", $time)};
  always @(u.ni) li = {li, $sformatf(" %0d", $time)};
  always @(u.nj) lj = {lj, $sformatf(" %0d", $time)};
  always @(u.nk) lk = {lk, $sformatf(" %0d", $time)};
  always @(u.nl) ll = {ll, $sformatf(" %0d", $time)};
  always @(u.nm) lm = {lm, $sformatf(" %0d", $time)};

  initial begin
    #10 r6 = 1;             // 10, and d6 never rises
    #1 r6 = 0;
  end

  initial begin
    #10 r7 = 1;             // 10
    #1 r7 = 0;
    #6 d7 = 1;              // 17
    #1 d7 = 0;
    #1 d7 = 1;              // 19
    #1 d7 = 0;
    #10 r7 = 1;             // 30
    #1 r7 = 0;
    #1 m7 = 0;
    #1 r7 = 1;              // 33, condition false
    #1 r7 = 0;
    #1 m7 = 1;
    #5 d7 = 1;              // 40
    #1 d7 = 0;
  end

  initial begin
    #10 r8 = 1;             // 10
    #1 r8 = 0;
    #2 r8 = 1;              // 13
    #1 r8 = 0;
    #3 d8 = 1;              // 17
    #1 d8 = 0;
    #12 r8 = 1;             // 30
    #1 r8 = 0;
    #1 m8 = 0;
    #1 r8 = 1;              // 33, condition false
    #1 r8 = 0;
    #1 m8 = 1;
    #2 d8 = 1;              // 37
    #1 d8 = 0;
    #2 r8 = 1;              // 40
    #1 r8 = 0;
  end

  initial begin
    #70 $display("$skew, no data event:%s", lf);
    $display("$timeskew, no data event:%s", lg);
    $display("$timeskew event-based:%s", lh);
    $display("$skew:%s", li);
    $display("$fullskew timer-based:%s", lj);
    $display("$fullskew timer-based, remain active:%s", lk);
    $display("$fullskew event-based:%s", ll);
    $display("$fullskew event-based, remain active:%s", lm);
  end
endmodule

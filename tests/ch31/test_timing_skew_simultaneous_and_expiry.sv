/*
:name: test_timing_skew_simultaneous_and_expiry
:description: $skew, $timeskew and $fullskew report no violation for reference and data events at the same time, even with zero limits, and $timeskew and $fullskew report none when a new timestamp event comes exactly when the limit expires (IEEE 1800-2023 Section 31.4.1)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.4.1 31.4.2 31.4.3 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_skew_simultaneous_and_expiry.expected
*/
// IEEE 1800-2023 §31.4.1, §31.4.2 and §31.4.3: $skew, $timeskew and $fullskew
// report a violation when (timecheck - timestamp) is greater than the limit,
// but reference and data events at the same time are never a violation, even
// when the limit is zero. $timeskew and $fullskew are timer-based by default:
// they report as soon as the limit has passed after the timestamp event, but
// not when a new timestamp event comes exactly when the limit expires; that
// event starts a new window. For $fullskew the first limit applies when the
// reference event comes first and the second when the data event does.
// §31.6: each violation toggles the notifier, which starts at 0. Each check
// has its own pair of signals; all events are rising edges.
//   $skew limit 0: r1 and d1 at 10 together: none; r1 at 20 and d1 at 21: 21.
//   $timeskew limit 0: r2 and d2 at 10 together: none.
//   $fullskew limits 0 and 0: r3 and d3 at 10 together: none.
//   $timeskew limit 5: r4 at 10 and again at 15, when the window expires:
//   none at 15; the new window expires at 20 without d4: 20.
//   $fullskew limits 5 and 8: r5 at 10 and 15: none at 15, then 20; d5 at 40
//   and again at 48, when its window of 8 expires: none at 48, then 56.
// The times at which each notifier changes are printed at the end.
//
// Icarus Verilog 13.0 skips timing checks, so the notifiers never change.

`timescale 1ns/1ns

module tss_checks (input r1, d1, r2, d2, r3, d3, r4, d4, r5, d5);
  reg na = 0, nb = 0, nc = 0, nd = 0, ne = 0;
  specify
    $skew(posedge r1, posedge d1, 0, na);
    $timeskew(posedge r2, posedge d2, 0, nb);
    $fullskew(posedge r3, posedge d3, 0, 0, nc);
    $timeskew(posedge r4, posedge d4, 5, nd);
    $fullskew(posedge r5, posedge d5, 5, 8, ne);
  endspecify
endmodule

module test_timing_skew_simultaneous_and_expiry;
  reg r1 = 0, d1 = 0, r2 = 0, d2 = 0, r3 = 0, d3 = 0, r4 = 0, d4 = 0, r5 = 0, d5 = 0;
  string la = "", lb = "", lc = "", ld = "", le = "";

  tss_checks u (r1, d1, r2, d2, r3, d3, r4, d4, r5, d5);

  always @(u.na) la = {la, $sformatf(" %0d", $time)};
  always @(u.nb) lb = {lb, $sformatf(" %0d", $time)};
  always @(u.nc) lc = {lc, $sformatf(" %0d", $time)};
  always @(u.nd) ld = {ld, $sformatf(" %0d", $time)};
  always @(u.ne) le = {le, $sformatf(" %0d", $time)};

  initial begin
    #10 r1 = 1; d1 = 1;     // 10: together
    #2 r1 = 0; d1 = 0;
    #8 r1 = 1;              // 20
    #1 d1 = 1;              // 21: 1 after
    #1 r1 = 0; d1 = 0;
  end

  initial begin
    #10 r2 = 1; d2 = 1; r3 = 1; d3 = 1;   // 10: together
    #2 r2 = 0; d2 = 0; r3 = 0; d3 = 0;
  end

  initial begin
    #10 r4 = 1; r5 = 1;     // 10
    #1 r4 = 0; r5 = 0;
    #4 r4 = 1; r5 = 1;      // 15: exactly when the window expires
    #1 r4 = 0; r5 = 0;
    #24 d5 = 1;             // 40
    #1 d5 = 0;
    #7 d5 = 1;              // 48: exactly when the window of 8 expires
    #1 d5 = 0;
  end

  initial begin
    #70 $display("$skew limit 0:%s", la);
    $display("$timeskew limit 0:%s", lb);
    $display("$fullskew limits 0 0:%s", lc);
    $display("$timeskew limit 5:%s", ld);
    $display("$fullskew limits 5 8:%s", le);
  end
endmodule

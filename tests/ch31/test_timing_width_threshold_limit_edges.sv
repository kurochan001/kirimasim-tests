/*
:name: test_timing_width_threshold_limit_edges
:description: $width reports a pulse only when its width is greater than the threshold and less than the limit, so pulses exactly as wide as the threshold or the limit are not reported, a threshold of 0 reports every narrower pulse, and $period, derived from one signal too, reports edges closer than its limit (IEEE 1800-2023 Section 31.4.4)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.4.4 31.4.5 31.4 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_width_threshold_limit_edges.expected
*/
// IEEE 1800-2023 §31.4.4: $width takes an edge-controlled reference event, a
// limit, a threshold and a notifier; the threshold and the notifier can be
// left out together (the threshold is then 0), and a threshold of 0 can be
// given explicitly with a notifier. The data event is the opposite edge of
// the same signal, and a violation is reported when threshold < (timecheck -
// timestamp) < limit. §31.4.5: $period takes the same edge of the same signal
// as data event and reports (timecheck - timestamp) < limit. §31.4: these
// checks compare the time between the two events derived from one signal
// with their limits. §31.6: each violation toggles the notifier, which starts
// at 0.
//
// c has high pulses of width 1, 2, 3, 4, 5 and 6 starting at 10, 20, ..., 60.
// $width(posedge c, 5, 2, nw) reports widths 3 and 4 at their falling edges
// 33 and 44: width 1 is a glitch below the threshold, width 2 equals it and
// width 5 equals the limit. $width(posedge c, 5, 0, nz) reports widths 1 to
// 4, at 11, 22, 33 and 44. $width(posedge c, 5) has neither threshold nor
// notifier. p rises at 10, 20, 29 and 39: $period(posedge p, 10, np) reports
// only the edge at 29, 9 after the one before. The times at which each
// notifier changes are printed at the end.
//
// Icarus Verilog 13.0 skips timing checks, so the notifiers never change.

`timescale 1ns/1ns

module twt_checks (input c, p);
  reg nw = 0, nz = 0, np = 0;
  specify
    $width(posedge c, 5, 2, nw);
    $width(posedge c, 5, 0, nz);
    $width(posedge c, 5);
    $period(posedge p, 10, np);
  endspecify
endmodule

module test_timing_width_threshold_limit_edges;
  reg c = 0, p = 0;
  string lw = "", lz = "", lp = "";

  twt_checks u (c, p);

  always @(u.nw) lw = {lw, $sformatf(" %0d", $time)};
  always @(u.nz) lz = {lz, $sformatf(" %0d", $time)};
  always @(u.np) lp = {lp, $sformatf(" %0d", $time)};

  initial begin
    for (int w = 1; w <= 6; w++) begin
      #(10 * w - $time) c = 1;   // 10, 20, ..., 60
      #(w) c = 0;                // a high pulse of width w
    end
  end

  initial begin
    #10 p = 1;          // 10
    #2 p = 0;
    #8 p = 1;           // 20: 10 after
    #2 p = 0;
    #7 p = 1;           // 29: 9 after
    #2 p = 0;
    #8 p = 1;           // 39: 10 after
    #2 p = 0;
  end

  initial begin
    #80 $display("$width limit 5 threshold 2:%s", lw);
    $display("$width limit 5 threshold 0:%s", lz);
    $display("$period limit 10:%s", lp);
  end
endmodule

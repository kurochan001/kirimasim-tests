/*
:name: test_timing_nochange_offset_directions
:description: The start offset of $nochange moves the beginning of its violation region earlier when positive and later when negative, the end offset moves its end later when positive and earlier when negative, and with both zero the region is the level after the reference edge (IEEE 1800-2023 Section 31.4.6)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.4.6 31.4 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_nochange_offset_directions.expected
*/
// IEEE 1800-2023 §31.4: $nochange involves three events, the two edges of the
// reference signal and the data event. §31.4.6: $nochange(posedge en, d,
// start, end) reports a data event during the high level of en, a region that
// a positive start offset begins earlier and a negative one later, and that a
// positive end offset ends later and a negative one earlier; with both
// offsets zero the region is the high level itself. §31.6: each violation
// toggles the notifier.
//
// Five checks share en and d: offsets (0, 0), (0, 2), (-2, 0), (2, 0) and
// (0, -2). en is high from 20 to 30, 50 to 60, 80 to 90, 110 to 120 and 140 to
// 150, and d changes once per pulse, never at the end of a region:
//   25, in the middle: all five report.
//   61, 1 after the trailing edge: only (0, 2), whose region ends at 62.
//   81, 1 after the leading edge: all but (-2, 0), whose region begins at 82.
//   109, 1 before the leading edge: only (2, 0), whose region begins at 108.
//   149, 1 before the trailing edge: all but (0, -2), whose region ends at 148.
// The test prints, for each pulse, how many times each notifier changed.
//
// Icarus Verilog 13.0 skips timing checks, so the notifiers never change.

`timescale 1ns/1ns

module tno_checks (input en, d);
  reg n00 = 0, ne2 = 0, nsm2 = 0, ns2 = 0, nem2 = 0;
  specify
    $nochange(posedge en, d, 0, 0, n00);
    $nochange(posedge en, d, 0, 2, ne2);
    $nochange(posedge en, d, -2, 0, nsm2);
    $nochange(posedge en, d, 2, 0, ns2);
    $nochange(posedge en, d, 0, -2, nem2);
  endspecify
endmodule

module test_timing_nochange_offset_directions;
  reg en = 0, d = 0;
  int c00 = 0, ce2 = 0, csm2 = 0, cs2 = 0, cem2 = 0;

  tno_checks u (en, d);

  always @(u.n00) c00++;
  always @(u.ne2) ce2++;
  always @(u.nsm2) csm2++;
  always @(u.ns2) cs2++;
  always @(u.nem2) cem2++;

  // en is high from start to start + 10; d changes at d_at; the counts are
  // printed 15 after the pulse ends and then cleared.
  task automatic pulse(int start, int d_at);
    fork
      begin #(start - $time) en = 1; #10 en = 0; end
      begin #(d_at - $time) d = ~d; end
    join
    #15;
    $display("d at %0d: (0,0) %0d (0,2) %0d (-2,0) %0d (2,0) %0d (0,-2) %0d",
             d_at, c00, ce2, csm2, cs2, cem2);
    c00 = 0;
    ce2 = 0;
    csm2 = 0;
    cs2 = 0;
    cem2 = 0;
  endtask

  initial begin
    pulse(20, 25);
    pulse(50, 61);
    pulse(80, 81);
    pulse(110, 109);
    pulse(140, 149);
  end
endmodule

/*
:name: test_sdf_tchk_skew_width_nochange
:description: An SDF SKEW entry annotates the limit of $skew and $timeskew, BIDIRECTSKEW both limits of $fullskew, WIDTH the limit of $width without changing its threshold, and NOCHANGE both offsets of $nochange (IEEE 1800-2023 Section 32.4.2)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.2 31.4.1 31.4.2 31.4.3 31.4.4 31.4.6 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_tchk_skew_width_nochange.expected
*/
// IEEE 1800-2023 §32.4.2, Table 32-2: (SKEW v1) annotates the limit of $skew
// and of $timeskew, (BIDIRECTSKEW v1 v2) the two limits of $fullskew,
// (WIDTH v1) the limit of $width but not its threshold, and (NOCHANGE v1 v2)
// the start and end offsets of $nochange. The instance ua gets these entries
// from the SDF file; u0, the same cell, gets none and keeps the limits of the
// specify block: 10 for the skew checks, 10 with threshold 2 for $width, and
// offsets 0 and 0 for $nochange.
//   r rises at 10 and d at 15: $skew (§31.4.1) reports 15 for a limit of 2;
//   $timeskew (§31.4.2), timer-based, reports at 12. Neither reports for 10.
//   fr rises at 10, 16 and 44, fd at 14, 40 and 45: with limits 2 and 3 the
//   timer-based $fullskew (§31.4.3) reports 12 (fd not 2 after fr) and 43 (fr
//   not 3 after fd); with 10 and 10 it reports 26 and 55 instead.
//   w has high pulses of 1, 3 and 7 from 10, 20 and 30: $width (§31.4.4)
//   reports only width 3, at 23, with limit 5 and threshold 2; with limit 10
//   it also reports width 7, at 37.
//   en is high from 50 to 60 and 70 to 80, and nd changes at 49 and 81: with
//   offsets 2 and 2 (§31.4.6) both changes are inside the region, with 0 and
//   0 neither is.
// §31.6: each violation toggles the notifier. The times at which the
// notifiers change, and how often the $nochange notifier changed, are printed
// at the end. The test creates its SDF file in the current directory.
//
// Icarus Verilog 13.0 skips timing checks, so the notifiers never change.

`timescale 1ns/1ns

module sdf_skw_cell (input r, d, fr, fd, w, en, nd);
  reg n_k = 0, n_t = 0, n_f = 0, n_w = 0, n_nc = 0;
  specify
    $skew(posedge r, posedge d, 10, n_k);
    $timeskew(posedge r, posedge d, 10, n_t);
    $fullskew(posedge fr, posedge fd, 10, 10, n_f);
    $width(posedge w, 10, 2, n_w);
    $nochange(posedge en, nd, 0, 0, n_nc);
  endspecify
endmodule

module test_sdf_tchk_skew_width_nochange;
  reg r = 0, d = 0, fr = 0, fd = 0, w = 0, en = 0, nd = 0;
  string s[8];
  int nca = 0, nc0 = 0;
  integer f;

  sdf_skw_cell ua (r, d, fr, fd, w, en, nd);
  sdf_skw_cell u0 (r, d, fr, fd, w, en, nd);

  always @(ua.n_k) s[0] = {s[0], $sformatf(" %0d", $time)};
  always @(ua.n_t) s[1] = {s[1], $sformatf(" %0d", $time)};
  always @(ua.n_f) s[2] = {s[2], $sformatf(" %0d", $time)};
  always @(ua.n_w) s[3] = {s[3], $sformatf(" %0d", $time)};
  always @(ua.n_nc) nca++;
  always @(u0.n_k) s[4] = {s[4], $sformatf(" %0d", $time)};
  always @(u0.n_t) s[5] = {s[5], $sformatf(" %0d", $time)};
  always @(u0.n_f) s[6] = {s[6], $sformatf(" %0d", $time)};
  always @(u0.n_w) s[7] = {s[7], $sformatf(" %0d", $time)};
  always @(u0.n_nc) nc0++;

  initial begin
    f = $fopen("test_sdf_tchk_skew_width_nochange.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_skw_cell\") (INSTANCE ua)");
    $fdisplay(f, "    (TIMINGCHECK");
    $fdisplay(f, "      (SKEW (posedge r) (posedge d) (2))");
    $fdisplay(f, "      (BIDIRECTSKEW (posedge fr) (posedge fd) (2) (3))");
    $fdisplay(f, "      (WIDTH (posedge w) (5))");
    $fdisplay(f, "      (NOCHANGE (posedge en) nd (2) (2)))))");
    $fclose(f);
    $sdf_annotate("test_sdf_tchk_skew_width_nochange.sdf");
  end

  initial begin
    #10 r = 1;           // 10
    #1 r = 0;
    #4 d = 1;            // 15
    #1 d = 0;
  end

  initial begin
    #10 fr = 1;          // 10
    #1 fr = 0;
    #3 fd = 1;           // 14
    #1 fd = 0;
    #1 fr = 1;           // 16
    #1 fr = 0;
    #23 fd = 1;          // 40
    #1 fd = 0;
    #3 fr = 1;           // 44
    #1 fr = 0; fd = 1;   // 45
    #1 fd = 0;
  end

  initial begin
    #10 w = 1;
    #1 w = 0;            // 11: width 1
    #9 w = 1;
    #3 w = 0;            // 23: width 3
    #7 w = 1;
    #7 w = 0;            // 37: width 7
  end

  initial begin
    #49 nd = 1;          // 49: 1 before the leading edge
    #1 en = 1;           // 50
    #10 en = 0;          // 60
    #10 en = 1;          // 70
    #10 en = 0;          // 80
    #1 nd = 0;           // 81: 1 after the trailing edge
  end

  initial begin
    #100 $display("ua: $skew:%s $timeskew:%s $fullskew:%s $width:%s $nochange changes: %0d",
                  s[0], s[1], s[2], s[3], nca);
    $display("u0: $skew:%s $timeskew:%s $fullskew:%s $width:%s $nochange changes: %0d",
             s[4], s[5], s[6], s[7], nc0);
  end
endmodule

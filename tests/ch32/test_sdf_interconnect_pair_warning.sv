/*
:name: test_sdf_interconnect_pair_warning
:description: INTERCONNECT entries give each source and load pair of a net its own delay, and an entry whose source does not exist or is not on the net of the load is reported with a warning but still annotates the load, as a delay from all its sources (IEEE 1800-2023 Section 32.4.4)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.4 32.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sdf_interconnect_pair_warning.expected
:expected_stderr_regex: (?i:\bwarn(?:ing)?\b|%Warning-)
*/
// IEEE 1800-2023 §32.4.4: on a net with several sources, INTERCONNECT can give
// a different delay to each pair of source and load port. If the source port
// of an entry is not found, or is not on the same net as the load port, the
// annotator issues a warning but annotates the delay to the load anyway; on a
// net with several sources that delay is then the delay from all of them.
// §32.3: the annotator warns about data it cannot annotate.
//
// The module pw_net has two tri-state drivers s1 and s2 on its net n, the load
// l, and a third driver s3 on another net m. The entries of each instance,
// with the resulting delays from s1 and from s2 to l.i, are:
//   wp: (INTERCONNECT s1.o l.i (2)) and (INTERCONNECT s2.o l.i (4)): 2 and 4.
//   wm: (INTERCONNECT nosuch.o l.i (3)), a source that does not exist: a
//       warning, and 3 and 3.
//   wu: (INTERCONNECT s3.o l.i (5)), a source on another net: a warning, and
//       5 and 5.
// Both drivers of n drive 1 and are disabled (z) at first. s1 is enabled from
// 10 to 30 and s2 from 50 to 70, so l.i goes to 1 and back to z after the
// delay from the driver that changed. The changes of l.i from time 10 on are
// recorded and printed at the end; the messages of the run have to contain a
// warning. The test creates its SDF file in the current directory.
//
// Icarus Verilog 13.0 cannot annotate an INTERCONNECT entry on a net with
// several sources ("Could not insert intermodpath").

`timescale 1ns/1ns

module pw_drv (input d, en, output o);
  bufif1 (o, d, en);
endmodule

module pw_load (input i, output o);
  assign o = i;
endmodule

module pw_net (input d, e1, e2, output lo, mo);
  wire n, m;
  pw_drv s1 (d, e1, n);
  pw_drv s2 (d, e2, n);
  pw_load l (n, lo);
  pw_drv s3 (d, e1, m);
  assign mo = m;
endmodule

module test_sdf_interconnect_pair_warning;
  reg d = 1, e1 = 0, e2 = 0;
  wire op, om, ou, mp, mm, mu;
  string lp = "", lm = "", lu = "";
  integer f;

  pw_net wp (d, e1, e2, op, mp);
  pw_net wm (d, e1, e2, om, mm);
  pw_net wu (d, e1, e2, ou, mu);

  always @(wp.l.i) if ($time >= 10) lp = {lp, $sformatf(" %0d:%b", $time, wp.l.i)};
  always @(wm.l.i) if ($time >= 10) lm = {lm, $sformatf(" %0d:%b", $time, wm.l.i)};
  always @(wu.l.i) if ($time >= 10) lu = {lu, $sformatf(" %0d:%b", $time, wu.l.i)};

  initial begin
    f = $fopen("test_sdf_interconnect_pair_warning.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"pw_net\") (INSTANCE wp)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (INTERCONNECT s1.o l.i (2)) (INTERCONNECT s2.o l.i (4)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"pw_net\") (INSTANCE wm)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (INTERCONNECT nosuch.o l.i (3)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"pw_net\") (INSTANCE wu)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (INTERCONNECT s3.o l.i (5))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_interconnect_pair_warning.sdf");
    #10 e1 = 1;     // 10: s1 drives 1
    #20 e1 = 0;     // 30: s1 lets go
    #20 e2 = 1;     // 50: s2 drives 1
    #20 e2 = 0;     // 70: s2 lets go
    #20 $display("wp l.i:%s", lp);
    $display("wm l.i:%s", lm);
    $display("wu l.i:%s", lu);
  end
endmodule

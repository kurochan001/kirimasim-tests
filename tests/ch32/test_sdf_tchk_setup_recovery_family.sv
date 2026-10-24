/*
:name: test_sdf_tchk_setup_recovery_family
:description: SDF SETUP, HOLD and SETUPHOLD entries annotate $setup, $hold and the matching limit of $setuphold, and RECOVERY, REMOVAL and RECREM entries annotate $recovery, $removal and the matching limit of $recrem, leaving the other limits as they were (IEEE 1800-2023 Section 32.4.2)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.2 32.4.1 31.3.1 31.3.2 31.3.3 31.3.4 31.3.5 31.3.6 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_tchk_setup_recovery_family.expected
*/
// IEEE 1800-2023 §32.4.2, Table 32-2: (SETUP v1) annotates $setup and the
// setup limit of $setuphold; (HOLD v1) annotates $hold and the hold limit of
// $setuphold; (SETUPHOLD v1 v2) annotates $setup with v1, $hold with v2 and
// both limits of $setuphold. (RECOVERY v1), (REMOVAL v1) and (RECREM v1 v2)
// do the same for $recovery, $removal and the recovery and removal limits of
// $recrem. A limit that an entry does not name keeps its value (§32.3).
// §32.4.1: a TIMINGCHECK entry annotates only checks of the matching type.
//
// Every check in the cells has the limit 1. The instances is, ih and ish of
// the first cell get (SETUP d (posedge clk) (4)), (HOLD d (posedge clk) (3))
// and (SETUPHOLD d (posedge clk) (4) (3)). d changes 3 before the clk edge at
// 20, a setup violation only for a setup limit of 4 (§31.3.1, §31.3.3), and 2
// after it, a hold violation only for a hold limit of 3 (§31.3.2): so is
// reports 20 in $setup and $setuphold, ih reports 22 in $hold and $setuphold,
// and ish reports both. The instances ir, im and irr of the second cell get
// (RECOVERY ... (4)), (REMOVAL ... (3)) and (RECREM ... (4) (3)). clk rises 3
// after rst at 10, a recovery violation at 13 only for a limit of 4 (§31.3.5),
// and rst rises 2 after clk at 30, a removal violation at 32 only for a limit
// of 3 (§31.3.4, §31.3.6). §31.6: each violation toggles the notifier. The
// times at which each notifier changes are printed at the end. The test
// creates its SDF file in the current directory.
//
// Icarus Verilog 13.0 skips timing checks, so the notifiers never change.

`timescale 1ns/1ns

module sdf_sh_family (input clk, d);
  reg n_s = 0, n_h = 0, n_sh = 0;
  specify
    $setup(d, posedge clk, 1, n_s);
    $hold(posedge clk, d, 1, n_h);
    $setuphold(posedge clk, d, 1, 1, n_sh);
  endspecify
endmodule

module sdf_rr_family (input rst, clk);
  reg n_rec = 0, n_rem = 0, n_rr = 0;
  specify
    $recovery(posedge rst, posedge clk, 1, n_rec);
    $removal(posedge rst, posedge clk, 1, n_rem);
    $recrem(posedge rst, posedge clk, 1, 1, n_rr);
  endspecify
endmodule

module test_sdf_tchk_setup_recovery_family;
  reg clk = 0, d = 0, rst = 0, rclk = 0;
  string s[18];
  integer f;

  sdf_sh_family is (clk, d);
  sdf_sh_family ih (clk, d);
  sdf_sh_family ish (clk, d);
  sdf_rr_family ir (rst, rclk);
  sdf_rr_family im (rst, rclk);
  sdf_rr_family irr (rst, rclk);

  always @(is.n_s) s[0] = {s[0], $sformatf(" %0d", $time)};
  always @(is.n_h) s[1] = {s[1], $sformatf(" %0d", $time)};
  always @(is.n_sh) s[2] = {s[2], $sformatf(" %0d", $time)};
  always @(ih.n_s) s[3] = {s[3], $sformatf(" %0d", $time)};
  always @(ih.n_h) s[4] = {s[4], $sformatf(" %0d", $time)};
  always @(ih.n_sh) s[5] = {s[5], $sformatf(" %0d", $time)};
  always @(ish.n_s) s[6] = {s[6], $sformatf(" %0d", $time)};
  always @(ish.n_h) s[7] = {s[7], $sformatf(" %0d", $time)};
  always @(ish.n_sh) s[8] = {s[8], $sformatf(" %0d", $time)};
  always @(ir.n_rec) s[9] = {s[9], $sformatf(" %0d", $time)};
  always @(ir.n_rem) s[10] = {s[10], $sformatf(" %0d", $time)};
  always @(ir.n_rr) s[11] = {s[11], $sformatf(" %0d", $time)};
  always @(im.n_rec) s[12] = {s[12], $sformatf(" %0d", $time)};
  always @(im.n_rem) s[13] = {s[13], $sformatf(" %0d", $time)};
  always @(im.n_rr) s[14] = {s[14], $sformatf(" %0d", $time)};
  always @(irr.n_rec) s[15] = {s[15], $sformatf(" %0d", $time)};
  always @(irr.n_rem) s[16] = {s[16], $sformatf(" %0d", $time)};
  always @(irr.n_rr) s[17] = {s[17], $sformatf(" %0d", $time)};

  initial begin
    f = $fopen("test_sdf_tchk_setup_recovery_family.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_sh_family\") (INSTANCE is)");
    $fdisplay(f, "    (TIMINGCHECK (SETUP d (posedge clk) (4))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_sh_family\") (INSTANCE ih)");
    $fdisplay(f, "    (TIMINGCHECK (HOLD d (posedge clk) (3))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_sh_family\") (INSTANCE ish)");
    $fdisplay(f, "    (TIMINGCHECK (SETUPHOLD d (posedge clk) (4) (3))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_rr_family\") (INSTANCE ir)");
    $fdisplay(f, "    (TIMINGCHECK (RECOVERY (posedge rst) (posedge clk) (4))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_rr_family\") (INSTANCE im)");
    $fdisplay(f, "    (TIMINGCHECK (REMOVAL (posedge rst) (posedge clk) (3))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_rr_family\") (INSTANCE irr)");
    $fdisplay(f, "    (TIMINGCHECK (RECREM (posedge rst) (posedge clk) (4) (3)))))");
    $fclose(f);
    $sdf_annotate("test_sdf_tchk_setup_recovery_family.sdf");
  end

  initial begin
    #17 d = 1;           // 17: 3 before the edge
    #3 clk = 1;          // 20
    #2 d = 0;            // 22: 2 after the edge
    #8 clk = 0;
  end

  initial begin
    #10 rst = 1;         // 10
    #3 rclk = 1;         // 13: 3 after rst
    #7 rst = 0; rclk = 0;
    #10 rclk = 1;        // 30
    #2 rst = 1;          // 32: 2 after clk
    #8 rst = 0; rclk = 0;
  end

  initial begin
    #60 $display("is: $setup:%s $hold:%s $setuphold:%s", s[0], s[1], s[2]);
    $display("ih: $setup:%s $hold:%s $setuphold:%s", s[3], s[4], s[5]);
    $display("ish: $setup:%s $hold:%s $setuphold:%s", s[6], s[7], s[8]);
    $display("ir: $recovery:%s $removal:%s $recrem:%s", s[9], s[10], s[11]);
    $display("im: $recovery:%s $removal:%s $recrem:%s", s[12], s[13], s[14]);
    $display("irr: $recovery:%s $removal:%s $recrem:%s", s[15], s[16], s[17]);
  end
endmodule

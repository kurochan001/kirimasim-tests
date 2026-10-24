/*
:name: test_sdf_interconnect_port_order_multisource
:description: On a net with two sources and one load, INTERCONNECT gives each source its own delay to the load, PORT gives one delay from all sources, an INTERCONNECT after a PORT changes only the delay from its source, and a PORT after an INTERCONNECT replaces the delays from all sources (IEEE 1800-2023 Section 32.5)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.5 32.4.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sdf_interconnect_port_order_multisource.expected
*/
// IEEE 1800-2023 §32.4.4: interconnect delays can be annotated to nets with
// one source and to nets with several; (PORT load ...) annotates the delay
// from all sources of the net to the load port, and (INTERCONNECT source load
// ...) the delay from that one source. §32.5: entries are annotated in order;
// an INTERCONNECT after a PORT to the same load changes only the delay from
// its source, and a PORT after an INTERCONNECT overwrites the delays from all
// sources.
//
// The module ms_net has two tri-state drivers s1 and s2 on its net n and the
// load l; the module ss_net has one driver s1 and the load l. The entries of
// each instance, with the resulting delays from s1 and from s2 to l.i, are:
//   wa: (PORT l.i (6)) then (INTERCONNECT s1.o l.i (2)): 2 and 6.
//   wb: (INTERCONNECT s1.o l.i (2)) then (PORT l.i (6)): 6 and 6.
//   wc: (INTERCONNECT s1.o l.i (2)) and (INTERCONNECT s2.o l.i (4)): 2 and 4.
//   wd: (PORT l.i (6)): 6 and 6.
//   ws: (INTERCONNECT s1.o l.i (5)) on the net with one source: 5.
// Both drivers drive 1 and are disabled (z) at first. s1 is enabled from 10 to
// 30 and s2 from 50 to 70, so l.i goes to 1 and back to z after the delay
// from the driver that changed. The changes of l.i from time 10 on are
// recorded and printed at the end. The test creates its SDF file in the
// current directory.
//
// Icarus Verilog 13.0 does not read PORT entries.

`timescale 1ns/1ns

module ms_drv (input d, en, output o);
  bufif1 (o, d, en);
endmodule

module ms_load (input i, output o);
  assign o = i;
endmodule

module ms_net (input d, e1, e2, output lo);
  wire n;
  ms_drv s1 (d, e1, n);
  ms_drv s2 (d, e2, n);
  ms_load l (n, lo);
endmodule

module ss_net (input d, e1, output lo);
  wire n;
  ms_drv s1 (d, e1, n);
  ms_load l (n, lo);
endmodule

module test_sdf_interconnect_port_order_multisource;
  reg d = 1, e1 = 0, e2 = 0;
  wire oa, ob, oc, od, os;
  string la = "", lb = "", lc = "", ld = "", ls = "";
  integer f;

  ms_net wa (d, e1, e2, oa);
  ms_net wb (d, e1, e2, ob);
  ms_net wc (d, e1, e2, oc);
  ms_net wd (d, e1, e2, od);
  ss_net ws (d, e1, os);

  always @(wa.l.i) if ($time >= 10) la = {la, $sformatf(" %0d:%b", $time, wa.l.i)};
  always @(wb.l.i) if ($time >= 10) lb = {lb, $sformatf(" %0d:%b", $time, wb.l.i)};
  always @(wc.l.i) if ($time >= 10) lc = {lc, $sformatf(" %0d:%b", $time, wc.l.i)};
  always @(wd.l.i) if ($time >= 10) ld = {ld, $sformatf(" %0d:%b", $time, wd.l.i)};
  always @(ws.l.i) if ($time >= 10) ls = {ls, $sformatf(" %0d:%b", $time, ws.l.i)};

  initial begin
    f = $fopen("test_sdf_interconnect_port_order_multisource.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"ms_net\") (INSTANCE wa)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (PORT l.i (6)) (INTERCONNECT s1.o l.i (2)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"ms_net\") (INSTANCE wb)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (INTERCONNECT s1.o l.i (2)) (PORT l.i (6)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"ms_net\") (INSTANCE wc)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (INTERCONNECT s1.o l.i (2)) (INTERCONNECT s2.o l.i (4)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"ms_net\") (INSTANCE wd)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (PORT l.i (6)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"ss_net\") (INSTANCE ws)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (INTERCONNECT s1.o l.i (5))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_interconnect_port_order_multisource.sdf");
    #10 e1 = 1;     // 10: s1 drives 1
    #20 e1 = 0;     // 30: s1 lets go
    #20 e2 = 1;     // 50: s2 drives 1
    #20 e2 = 0;     // 70: s2 lets go
    #20 $display("wa l.i:%s", la);
    $display("wb l.i:%s", lb);
    $display("wc l.i:%s", lc);
    $display("wd l.i:%s", ld);
    $display("ws l.i:%s", ls);
  end
endmodule

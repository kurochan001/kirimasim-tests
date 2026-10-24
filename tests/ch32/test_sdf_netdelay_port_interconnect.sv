/*
:name: test_sdf_netdelay_port_interconnect
:description: In an SDF file of a version that has NETDELAY, NETDELAY on a net delays every load port of the net from all its sources and NETDELAY on a port only that load, and PORT and INTERCONNECT annotate interconnect delays in the same file (IEEE 1800-2023 Section 32.4.4)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sdf_netdelay_port_interconnect.expected
*/
// IEEE 1800-2023 §32.4.4, Table 32-3: PORT, NETDELAY and INTERCONNECT all
// annotate interconnect delays; NETDELAY exists in OVI SDF 1.0, 2.0 and 2.1
// and IEEE SDF 4.0. NETDELAY on an input port annotates that load port; on a
// net it annotates every load port of the net; if the net has more than one
// source, the delay is from all of them. PORT annotates its load port with a
// delay from all sources, INTERCONNECT the delay from one source to one load.
//
// The SDF file has version 2.1. In the instance w, the net n has the
// tri-state sources s1 and s2 and the loads l1 and l2, and gets
// (NETDELAY n (4)). The net m has the source s3 and the loads l3, l4, l5 and
// l6; l3 gets (NETDELAY l3.i (5)), l5 (PORT l5.i (6)) and l6
// (INTERCONNECT s3.o l6.i (7)), and l4 nothing. s1 drives 1 from 10 to 30 and
// s2 from 50 to 70, so l1.i and l2.i are 1 from 14 to 34 and from 54 to 74.
// s3 follows b, which is 1 from 10 to 20: l3.i, l4.i, l5.i and l6.i follow it
// 5, 0, 6 and 7 later. The changes of each load port from time 10 on are
// recorded and printed at the end. The test creates its SDF file in the
// current directory.
//
// Icarus Verilog 13.0 does not read NETDELAY and PORT entries.

`timescale 1ns/1ns

module nd_drv (input d, en, output o);
  bufif1 (o, d, en);
endmodule

module nd_load (input i, output o);
  assign o = i;
endmodule

module nd_net (input d, e1, e2, b, output [5:0] lo);
  wire n, m;
  nd_drv s1 (d, e1, n);
  nd_drv s2 (d, e2, n);
  nd_load l1 (n, lo[0]);
  nd_load l2 (n, lo[1]);
  nd_drv s3 (b, 1'b1, m);
  nd_load l3 (m, lo[2]);
  nd_load l4 (m, lo[3]);
  nd_load l5 (m, lo[4]);
  nd_load l6 (m, lo[5]);
endmodule

module test_sdf_netdelay_port_interconnect;
  reg d = 1, e1 = 0, e2 = 0, b = 0;
  wire [5:0] lo;
  string s1 = "", s2 = "", s3 = "", s4 = "", s5 = "", s6 = "";
  integer f;

  nd_net w (d, e1, e2, b, lo);

  always @(w.l1.i) if ($time >= 10) s1 = {s1, $sformatf(" %0d:%b", $time, w.l1.i)};
  always @(w.l2.i) if ($time >= 10) s2 = {s2, $sformatf(" %0d:%b", $time, w.l2.i)};
  always @(w.l3.i) if ($time >= 10) s3 = {s3, $sformatf(" %0d:%b", $time, w.l3.i)};
  always @(w.l4.i) if ($time >= 10) s4 = {s4, $sformatf(" %0d:%b", $time, w.l4.i)};
  always @(w.l5.i) if ($time >= 10) s5 = {s5, $sformatf(" %0d:%b", $time, w.l5.i)};
  always @(w.l6.i) if ($time >= 10) s6 = {s6, $sformatf(" %0d:%b", $time, w.l6.i)};

  initial begin
    f = $fopen("test_sdf_netdelay_port_interconnect.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"2.1\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"nd_net\") (INSTANCE w)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (NETDELAY n (4))");
    $fdisplay(f, "      (NETDELAY l3.i (5))");
    $fdisplay(f, "      (PORT l5.i (6))");
    $fdisplay(f, "      (INTERCONNECT s3.o l6.i (7))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_netdelay_port_interconnect.sdf");
    #10 e1 = 1; b = 1;  // 10: s1 drives 1, b rises
    #10 b = 0;          // 20
    #10 e1 = 0;         // 30: s1 lets go
    #20 e2 = 1;         // 50: s2 drives 1
    #20 e2 = 0;         // 70: s2 lets go
    #20 $display("l1.i:%s", s1);
    $display("l2.i:%s", s2);
    $display("l3.i:%s", s3);
    $display("l4.i:%s", s4);
    $display("l5.i:%s", s5);
    $display("l6.i:%s", s6);
  end
endmodule

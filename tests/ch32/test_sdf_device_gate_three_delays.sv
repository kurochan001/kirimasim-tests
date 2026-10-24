/*
:name: test_sdf_device_gate_three_delays
:description: SDF delays annotated to a gate primitive are at most three: one or two values are extended by the rules for gate delays, values after the third are ignored, and the delay to x is the smallest of the three (IEEE 1800-2023 Section 32.8)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.8 32.4.1 28.16
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sdf_device_gate_three_delays.expected
*/
// IEEE 1800-2023 §32.8: specify paths and interconnects have up to twelve
// transition delays, while other constructs, such as gate primitives, have
// only three; fewer than three SDF values are extended as Table 28-9 says,
// values after the third are ignored, and the delay to x is the smallest of
// the three. §32.4.1: (DEVICE ...) in a cell without specify paths annotates
// the primitives that drive its outputs. §28.16, Table 28-9: with two delays
// the transitions to z and to x take the smaller one; with three (d1, d2, d3)
// the transitions to 1 take d1, to 0 d2, to z d3 and to x min(d1, d2, d3).
//
// The cell is a bufif1 without delay and without specify block. The instances
// get (DEVICE (5)); (DEVICE (3) (7)); (DEVICE (6) (4) (2)); six values 2 to 7;
// and twelve values 2 to 13. The last two act as (2, 3, 4): 0->1 2, 1->0 3,
// 0->z 4, z->1 2, 1->z 4, z->0 3, to x 2, x->z 4, where a module path with the
// same six values would have z->1 5, 1->z 6 and z->0 7. With (6, 4, 2) every
// transition to x takes 2, the third value.
//
// A bufif1 drives each output, so that the output can be 0, 1, x (data x) and
// z (enable 0). The stimulus makes each of the twelve transitions at least
// once, 20 time units apart, which is longer than any delay. The changes of
// each output from time 20 on are recorded and printed at the end. The test
// creates its SDF file in the current directory.
//
// Icarus Verilog 13.0 does not read DEVICE entries.

`timescale 1ns/1ns

module dg_cell (input d, en, output y);
  bufif1 (y, d, en);
endmodule

module test_sdf_device_gate_three_delays;
  reg d, en;
  wire y1, y2, y3, y6, y12;
  string l1 = "", l2 = "", l3 = "", l6 = "", l12 = "";
  integer f;

  dg_cell g1 (d, en, y1);
  dg_cell g2 (d, en, y2);
  dg_cell g3 (d, en, y3);
  dg_cell g6 (d, en, y6);
  dg_cell g12 (d, en, y12);

  always @(y1) if ($time >= 20) l1 = {l1, $sformatf(" %0d:%b", $time, y1)};
  always @(y2) if ($time >= 20) l2 = {l2, $sformatf(" %0d:%b", $time, y2)};
  always @(y3) if ($time >= 20) l3 = {l3, $sformatf(" %0d:%b", $time, y3)};
  always @(y6) if ($time >= 20) l6 = {l6, $sformatf(" %0d:%b", $time, y6)};
  always @(y12) if ($time >= 20) l12 = {l12, $sformatf(" %0d:%b", $time, y12)};

  initial begin
    f = $fopen("test_sdf_device_gate_three_delays.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"dg_cell\") (INSTANCE g1)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (DEVICE (5)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"dg_cell\") (INSTANCE g2)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (DEVICE (3) (7)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"dg_cell\") (INSTANCE g3)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (DEVICE (6) (4) (2)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"dg_cell\") (INSTANCE g6)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (DEVICE (2) (3) (4) (5) (6) (7)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"dg_cell\") (INSTANCE g12)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (DEVICE (2) (3) (4) (5) (6) (7)");
    $fdisplay(f, "                             (8) (9) (10) (11) (12) (13))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_device_gate_three_delays.sdf");
    d = 0;
    en = 1;
    #20 d = 1;      // 20: 0->1
    #20 d = 0;      // 40: 1->0
    #20 en = 0;     // 60: 0->z
    #20 d = 1;      // 80: output stays z
    #10 en = 1;     // 90: z->1
    #20 en = 0;     // 110: 1->z
    #20 d = 0;      // 130: output stays z
    #10 en = 1;     // 140: z->0
    #20 d = 1'bx;   // 160: 0->x
    #20 d = 1;      // 180: x->1
    #20 d = 1'bx;   // 200: 1->x
    #20 d = 0;      // 220: x->0
    #20 d = 1'bx;   // 240: 0->x
    #20 en = 0;     // 260: x->z
    #20 en = 1;     // 280: z->x
    #20 d = 0;      // 300: x->0
    #20 $display("g1:%s", l1);
    $display("g2:%s", l2);
    $display("g3:%s", l3);
    $display("g6:%s", l6);
    $display("g12:%s", l12);
  end
endmodule

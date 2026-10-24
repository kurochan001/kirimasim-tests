/*
:name: test_sdf_iopath_one_two_three_values
:description: One, two and three SDF delay values on an IOPATH entry are extended to the twelve transitions of the module path as Table 32-4 gives, including the minimum and maximum rules for the x transitions (IEEE 1800-2023 Section 32.8)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.8 32.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sdf_iopath_one_two_three_values.expected
*/
// IEEE 1800-2023 §32.8, Table 32-4: one SDF value v1 annotates every
// transition of a module path. Two values give 0->1, 0->z, z->1, 0->x and
// x->1 v1, 1->0, 1->z, z->0, 1->x and x->0 v2, x->z max(v1, v2) and z->x
// min(v1, v2). Three values give 0->1, z->1 and x->1 v1, 1->0, z->0 and x->0
// v2, 0->z, 1->z and x->z v3, 0->x min(v1, v3), 1->x min(v2, v3) and z->x
// min(v1, v2). §32.4.1: an IOPATH entry annotates the module path between its
// two ports.
//
// Every instance of the cell has the specify delay 1 on its paths from d and
// en to y, and the SDF file annotates both paths of each instance. u1 gets
// (5). u2a gets (3) (7) and u2b (8) (4), so x->z is 7 and 8 and z->x 3 and 4.
// u3a gets (3) (6) (9): 0->x 3, 1->x 6, z->x 3; u3b gets (7) (4) (2): 0->x 2,
// 1->x 2, z->x 4. With the pairs the other way round in the two instances,
// the minimum and the maximum differ from a value at a fixed position. A
// delay of 1 would mean that the entry was not annotated.
//
// A bufif1 drives each output, so that the output can be 0, 1, x (data x) and
// z (enable 0). The stimulus makes each of the twelve transitions at least
// once, 20 time units apart, which is longer than any delay, so no pulse is
// filtered. The changes of each output from time 20 on are recorded and
// printed at the end. The test creates its SDF file in the current directory.

`timescale 1ns/1ns

module sdf_ot_cell (input d, en, output y);
  bufif1 (y, d, en);
  specify
    (d, en *> y) = 1;
  endspecify
endmodule

module test_sdf_iopath_one_two_three_values;
  reg d, en;
  wire y1, y2a, y2b, y3a, y3b;
  string log1 = "", log2a = "", log2b = "", log3a = "", log3b = "";
  integer f;

  sdf_ot_cell u1 (d, en, y1);
  sdf_ot_cell u2a (d, en, y2a);
  sdf_ot_cell u2b (d, en, y2b);
  sdf_ot_cell u3a (d, en, y3a);
  sdf_ot_cell u3b (d, en, y3b);

  always @(y1) if ($time >= 20) log1 = {log1, $sformatf(" %0d:%b", $time, y1)};
  always @(y2a) if ($time >= 20) log2a = {log2a, $sformatf(" %0d:%b", $time, y2a)};
  always @(y2b) if ($time >= 20) log2b = {log2b, $sformatf(" %0d:%b", $time, y2b)};
  always @(y3a) if ($time >= 20) log3a = {log3a, $sformatf(" %0d:%b", $time, y3a)};
  always @(y3b) if ($time >= 20) log3b = {log3b, $sformatf(" %0d:%b", $time, y3b)};

  initial begin
    f = $fopen("test_sdf_iopath_one_two_three_values.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_ot_cell\") (INSTANCE u1)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (IOPATH d y (5)) (IOPATH en y (5)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_ot_cell\") (INSTANCE u2a)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (IOPATH d y (3) (7)) (IOPATH en y (3) (7)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_ot_cell\") (INSTANCE u2b)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (IOPATH d y (8) (4)) (IOPATH en y (8) (4)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_ot_cell\") (INSTANCE u3a)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (IOPATH d y (3) (6) (9)) (IOPATH en y (3) (6) (9)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_ot_cell\") (INSTANCE u3b)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (IOPATH d y (7) (4) (2)) (IOPATH en y (7) (4) (2))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_iopath_one_two_three_values.sdf");
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
    #20 $display("y1:%s", log1);
    $display("y2a:%s", log2a);
    $display("y2b:%s", log2b);
    $display("y3a:%s", log3a);
    $display("y3b:%s", log3b);
  end
endmodule

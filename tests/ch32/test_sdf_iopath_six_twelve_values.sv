/*
:name: test_sdf_iopath_six_twelve_values
:description: Twelve SDF delay values annotate the twelve transitions of a module path in their order, and six values annotate the transitions among 0, 1 and z, with the x transitions taken as the minimum or the maximum of two of them (IEEE 1800-2023 Section 32.8)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.8 32.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sdf_iopath_six_twelve_values.expected
*/
// IEEE 1800-2023 §32.8, Table 32-4: SDF values v1 to v12 annotate a module
// path with the delays 0->1 v1, 1->0 v2, 0->z v3, z->1 v4, 1->z v5, z->0 v6,
// 0->x v7, x->1 v8, 1->x v9, x->0 v10, x->z v11 and z->x v12. With six values
// the first six are the same, and 0->x is min(v1, v3), x->1 max(v1, v4), 1->x
// min(v2, v5), x->0 max(v2, v6), x->z max(v3, v5) and z->x min(v4, v6).
// §32.4.1: an IOPATH entry annotates the module path between its two ports.
//
// Every instance of the cell has the specify delay 1 on its paths from d and
// en to y, and the SDF file annotates both paths of each instance. u12 gets
// the twelve values 2 to 13, all different. u6a gets (2, 3, 4, 5, 6, 7), so
// 0->x is 2, x->1 5, 1->x 3, x->0 7, x->z 6 and z->x 5; u6b gets (9, 8, 4, 6,
// 3, 5), which turns each pair round: 0->x 4, x->1 9, 1->x 3, x->0 8, x->z 4
// and z->x 5. A delay of 1 would mean that the entry was not annotated.
//
// A bufif1 drives each output, so that the output can be 0, 1, x (data x) and
// z (enable 0). The stimulus makes each of the twelve transitions at least
// once, 20 time units apart, which is longer than any delay, so no pulse is
// filtered. The changes of each output from time 20 on are recorded and
// printed at the end. The test creates its SDF file in the current directory.

`timescale 1ns/1ns

module sdf_tw_cell (input d, en, output y);
  bufif1 (y, d, en);
  specify
    (d, en *> y) = 1;
  endspecify
endmodule

module test_sdf_iopath_six_twelve_values;
  reg d, en;
  wire y12, y6a, y6b;
  string log12 = "", log6a = "", log6b = "";
  integer f;

  sdf_tw_cell u12 (d, en, y12);
  sdf_tw_cell u6a (d, en, y6a);
  sdf_tw_cell u6b (d, en, y6b);

  always @(y12) if ($time >= 20) log12 = {log12, $sformatf(" %0d:%b", $time, y12)};
  always @(y6a) if ($time >= 20) log6a = {log6a, $sformatf(" %0d:%b", $time, y6a)};
  always @(y6b) if ($time >= 20) log6b = {log6b, $sformatf(" %0d:%b", $time, y6b)};

  initial begin
    f = $fopen("test_sdf_iopath_six_twelve_values.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_tw_cell\") (INSTANCE u12)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (IOPATH d y (2) (3) (4) (5) (6) (7) (8) (9) (10) (11) (12) (13))");
    $fdisplay(f, "      (IOPATH en y (2) (3) (4) (5) (6) (7) (8) (9) (10) (11) (12) (13)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_tw_cell\") (INSTANCE u6a)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (IOPATH d y (2) (3) (4) (5) (6) (7))");
    $fdisplay(f, "      (IOPATH en y (2) (3) (4) (5) (6) (7)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_tw_cell\") (INSTANCE u6b)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (IOPATH d y (9) (8) (4) (6) (3) (5))");
    $fdisplay(f, "      (IOPATH en y (9) (8) (4) (6) (3) (5))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_iopath_six_twelve_values.sdf");
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
    #20 $display("y12:%s", log12);
    $display("y6a:%s", log6a);
    $display("y6b:%s", log6b);
  end
endmodule

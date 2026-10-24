/*
:name: test_sdf_interconnect_transition_values
:description: An interconnect delay has a delay for each of the twelve transitions, so twelve SDF values on an INTERCONNECT entry reach the load in their own order, and two values are extended to the twelve transitions by the rules for module path delays (IEEE 1800-2023 Section 32.4.4)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.4 32.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sdf_interconnect_transition_values.expected
*/
// IEEE 1800-2023 §32.4.4: an INTERCONNECT entry annotates an interconnect
// delay from an output port (the source) to an input port (the load); an
// interconnect delay has twelve transition delays, and missing ones are filled
// in by the same rules as for module path delays. §32.8, Table 32-4: twelve
// values v1 to v12 are the delays of 0->1, 1->0, 0->z, z->1, 1->z, z->0, 0->x,
// x->1, 1->x, x->0, x->z and z->x; two values give 0->1, 0->z, z->1, 0->x and
// x->1 v1, 1->0, 1->z, z->0, 1->x and x->0 v2, x->z max(v1, v2) and z->x
// min(v1, v2).
//
// The source module drives its output port with a bufif1 and no delay, so the
// port can be 0, 1, x and z; the load module takes it on its input port. The
// entry from s12.o to l12.i has the twelve values 2 to 13, all different; the
// entry from s2.o to l2.i has (3) (7), so 1->z and 1->x take 7 and x->z 7,
// where the rules for gate delays would give 3. The stimulus makes each of
// the twelve transitions at least once, 20 time units apart, and the changes
// of each load port from time 20 on are recorded and printed at the end. The
// entries belong to the cell of this module, named by an empty INSTANCE; the
// test creates its SDF file in the current directory.

`timescale 1ns/1ns

module ic_src (input d, en, output o);
  bufif1 (o, d, en);
endmodule

module ic_load (input i, output o);
  assign o = i;
endmodule

module test_sdf_interconnect_transition_values;
  reg d, en;
  wire n12, n2, o12, o2;
  string log12 = "", log2 = "";
  integer f;

  ic_src s12 (d, en, n12);
  ic_load l12 (n12, o12);
  ic_src s2 (d, en, n2);
  ic_load l2 (n2, o2);

  always @(l12.i) if ($time >= 20) log12 = {log12, $sformatf(" %0d:%b", $time, l12.i)};
  always @(l2.i) if ($time >= 20) log2 = {log2, $sformatf(" %0d:%b", $time, l2.i)};

  initial begin
    f = $fopen("test_sdf_interconnect_transition_values.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"test_sdf_interconnect_transition_values\") (INSTANCE)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (INTERCONNECT s12.o l12.i (2) (3) (4) (5) (6) (7)");
    $fdisplay(f, "                                (8) (9) (10) (11) (12) (13))");
    $fdisplay(f, "      (INTERCONNECT s2.o l2.i (3) (7))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_interconnect_transition_values.sdf");
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
    #20 $display("l12.i:%s", log12);
    $display("l2.i:%s", log2);
  end
endmodule

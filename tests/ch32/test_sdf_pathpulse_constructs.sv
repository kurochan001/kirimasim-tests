/*
:name: test_sdf_pathpulse_constructs
:description: The SDF constructs PATHPULSE and PATHPULSEPERCENT set the pulse limits of conditional and unconditional module paths between the named ports without changing their delays, and PATHPULSE limits larger than the delay act as limits equal to it (IEEE 1800-2023 Section 32.4.1)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.1 32.7 30.7
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sdf_pathpulse_constructs.expected
*/
// IEEE 1800-2023 §32.4.1, Table 32-1: (PATHPULSE ...) and (PATHPULSEPERCENT
// ...) annotate the pulse limits of the conditional and the unconditional
// module paths between the two ports they name. §32.7: they change only the
// pulse limits, not the delay, and PATHPULSE limits larger than the delay
// behave like limits equal to the delay. PATHPULSE gives the reject and the
// error limit; PATHPULSEPERCENT gives them as percentages of the delay.
// §30.7: a pulse narrower than the reject limit is rejected, one narrower
// than the error limit becomes x (from the scheduled time of its leading edge
// to that of its trailing edge), and a wider one passes.
//
// The cell has the conditional paths if (s) (a => y) and if (!s) (a => y) and
// the unconditional path (a => z), all with the delay 10. The instances u1
// (s = 1) and u0 (s = 0) get (PATHPULSE a y (2) (5)) and (PATHPULSE a z (2)
// (5)); v1 and v0 get (PATHPULSEPERCENT a y (20) (50)) and the same for a z,
// which is again 2 and 5. In all eight outputs a pulse of width 1 on p is
// rejected, widths 2 to 4 become x and 5 and 6 pass, 10 after p: the delay
// stays 10. The instance ub, a buffer with the delay 6, gets (PATHPULSE a y
// (9) (10)), which acts as 6 and 6: widths 1 to 5 are rejected and width 6,
// which is not narrower than the delay, passes.
// The changes of each output from time 20 on are recorded and printed at the
// end. The test creates its SDF file in the current directory.
//
// Icarus Verilog 13.0 does not read PATHPULSE and PATHPULSEPERCENT entries.

`timescale 1ns/1ns

module sdf_pp_cell (input a, s, output y, z);
  buf (y, a);
  buf (z, a);
  specify
    if (s) (a => y) = 10;
    if (!s) (a => y) = 10;
    (a => z) = 10;
  endspecify
endmodule

module sdf_pp_buf (input a, output y);
  buf (y, a);
  specify
    (a => y) = 6;
  endspecify
endmodule

module test_sdf_pathpulse_constructs;
  reg p = 0, one = 1, zero = 0;
  wire u1y, u1z, u0y, u0z, v1y, v1z, v0y, v0z, uby;
  string l0 = "", l1 = "", l2 = "", l3 = "", l4 = "", l5 = "", l6 = "", l7 = "", l8 = "";
  integer f;

  sdf_pp_cell u1 (p, one, u1y, u1z);
  sdf_pp_cell u0 (p, zero, u0y, u0z);
  sdf_pp_cell v1 (p, one, v1y, v1z);
  sdf_pp_cell v0 (p, zero, v0y, v0z);
  sdf_pp_buf ub (p, uby);

  always @(u1y) if ($time >= 20) l0 = {l0, $sformatf(" %0d:%b", $time, u1y)};
  always @(u1z) if ($time >= 20) l1 = {l1, $sformatf(" %0d:%b", $time, u1z)};
  always @(u0y) if ($time >= 20) l2 = {l2, $sformatf(" %0d:%b", $time, u0y)};
  always @(u0z) if ($time >= 20) l3 = {l3, $sformatf(" %0d:%b", $time, u0z)};
  always @(v1y) if ($time >= 20) l4 = {l4, $sformatf(" %0d:%b", $time, v1y)};
  always @(v1z) if ($time >= 20) l5 = {l5, $sformatf(" %0d:%b", $time, v1z)};
  always @(v0y) if ($time >= 20) l6 = {l6, $sformatf(" %0d:%b", $time, v0y)};
  always @(v0z) if ($time >= 20) l7 = {l7, $sformatf(" %0d:%b", $time, v0z)};
  always @(uby) if ($time >= 20) l8 = {l8, $sformatf(" %0d:%b", $time, uby)};

  initial begin
    f = $fopen("test_sdf_pathpulse_constructs.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_pp_cell\") (INSTANCE u1)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (PATHPULSE a y (2) (5)) (PATHPULSE a z (2) (5)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_pp_cell\") (INSTANCE u0)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (PATHPULSE a y (2) (5)) (PATHPULSE a z (2) (5)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_pp_cell\") (INSTANCE v1)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (PATHPULSEPERCENT a y (20) (50))");
    $fdisplay(f, "      (PATHPULSEPERCENT a z (20) (50)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_pp_cell\") (INSTANCE v0)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (PATHPULSEPERCENT a y (20) (50))");
    $fdisplay(f, "      (PATHPULSEPERCENT a z (20) (50)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_pp_buf\") (INSTANCE ub)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (PATHPULSE a y (9) (10))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_pathpulse_constructs.sdf");
    #20 p = 1;
    #1 p = 0;     // 20 to 21: width 1
    #19 p = 1;
    #2 p = 0;     // 40 to 42: width 2
    #18 p = 1;
    #3 p = 0;     // 60 to 63: width 3
    #17 p = 1;
    #4 p = 0;     // 80 to 84: width 4
    #16 p = 1;
    #5 p = 0;     // 100 to 105: width 5
    #15 p = 1;
    #6 p = 0;     // 120 to 126: width 6
    #24 $display("u1 y:%s", l0);
    $display("u1 z:%s", l1);
    $display("u0 y:%s", l2);
    $display("u0 z:%s", l3);
    $display("v1 y:%s", l4);
    $display("v1 z:%s", l5);
    $display("v0 y:%s", l6);
    $display("v0 z:%s", l7);
    $display("ub y:%s", l8);
  end
endmodule

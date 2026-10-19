/*
:name: test_sdf_iopath_all_conditional_paths
:description: An IOPATH entry without a condition annotates every module path between the same two ports, whatever their conditions (IEEE 1800-2023 Section 32.4.1)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.1 30.4.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_iopath_all_conditional_paths.expected
*/
// IEEE 1800-2023 §32.4.1: an IOPATH entry without COND annotates all module
// paths between its two ports, including state-dependent ones (30.4.4). Both
// paths from a to y, one for s = 1 and one for s = 0, get the delay 6, so y
// follows a after 6 whatever s is. The path to z is not in the SDF file and
// keeps its delay of 2.

`timescale 1ns/1ns

module sdf_condpath_cell(output y, output z, input a, input s);
  buf (y, a);
  buf (z, a);
  specify
    if (s) (a => y) = 1;
    if (!s) (a => y) = 1;
    (a => z) = 2;
  endspecify
endmodule

module test_sdf_iopath_all_conditional_paths;
  reg a = 0, s = 1;
  wire y, z;
  integer f;

  sdf_condpath_cell u(y, z, a, s);

  initial begin
    f = $fopen("test_sdf_iopath_all_conditional_paths.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_condpath_cell\") (INSTANCE u)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (IOPATH a y (6))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_iopath_all_conditional_paths.sdf");
    #10 a = 1;      // 10, s = 1
    #20 s = 0;
    #10 a = 0;      // 40, s = 0
    #10 $finish;
  end

  always @(y or z) if ($time >= 10) $display("%0d: y=%b z=%b", $time, y, z);
endmodule

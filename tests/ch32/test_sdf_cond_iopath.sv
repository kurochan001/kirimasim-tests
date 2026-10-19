/*
:name: test_sdf_cond_iopath
:description: COND annotates only the module path with the same condition, and CONDELSE annotates the ifnone path (IEEE 1800-2023 Section 32.4.1)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.1 30.4.4 30.4.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_cond_iopath.expected
*/
// IEEE 1800-2023 §32.4.1, Table 32-1: (COND s (IOPATH a y ...)) annotates only
// the path from a to y whose condition is s, not the one for !s; (CONDELSE
// (IOPATH ...)) annotates the ifnone path (30.4.4.3). The path from a to z for
// s = 1 keeps its delay of 1, and its ifnone path, used when s = 0, gets 8.
// Icarus Verilog 13.0 leaves all four paths at their specify delays. Verilator
// 5.052 ignores $sdf_annotate and module path delays.

`timescale 1ns/1ns

module sdf_cond_cell(output y, output z, input a, input s);
  buf (y, a);
  buf (z, a);
  specify
    if (s) (a => y) = 1;
    if (!s) (a => y) = 1;
    if (s) (a => z) = 1;
    ifnone (a => z) = 1;
  endspecify
endmodule

module test_sdf_cond_iopath;
  reg a = 0, s = 1;
  wire y, z;
  integer f;

  sdf_cond_cell u(y, z, a, s);

  initial begin
    f = $fopen("test_sdf_cond_iopath.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_cond_cell\") (INSTANCE u)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (COND s (IOPATH a y (6)))");
    $fdisplay(f, "      (CONDELSE (IOPATH a z (8)))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_cond_iopath.sdf");
    #10 a = 1;      // 10, s = 1: y after 6, z after 1
    #20 s = 0;
    #10 a = 0;      // 40, s = 0: y after 1, z after 8 (ifnone)
    #10 $finish;
  end

  always @(y or z) if ($time >= 10) $display("%0d: y=%b z=%b", $time, y, z);
endmodule

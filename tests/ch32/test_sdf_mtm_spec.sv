/*
:name: test_sdf_mtm_spec
:description: The mtm_spec argument of $sdf_annotate chooses the minimum or the maximum of each min:typ:max triple in the SDF file (IEEE 1800-2023 Section 32.9)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.9 32.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_mtm_spec.expected
*/
// IEEE 1800-2023 §32.9, Table 32-5: the fifth argument of $sdf_annotate,
// mtm_spec, chooses which value of a min:typ:max triple is annotated. The same
// file, with the triple (2:4:6), is annotated into p1 with "MINIMUM" and into
// p2 with "MAXIMUM" (32.6), so the two instances of the cell get 2 and 6. The
// config_file and log_file arguments are left empty. Icarus Verilog 13.0 uses
// only the first two arguments of $sdf_annotate. Verilator 5.052 ignores
// $sdf_annotate and module path delays.

`timescale 1ns/1ns

module sdf_mtm_cell(output y, input a);
  buf (y, a);
  specify
    (a => y) = 1;
  endspecify
endmodule

module sdf_mtm_wrap(output y, input a);
  sdf_mtm_cell c(y, a);
endmodule

module test_sdf_mtm_spec;
  reg a = 0;
  wire y1, y2;
  integer f;

  sdf_mtm_wrap p1(y1, a);
  sdf_mtm_wrap p2(y2, a);

  initial begin
    f = $fopen("test_sdf_mtm_spec.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_mtm_cell\") (INSTANCE c)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (IOPATH a y (2:4:6))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_mtm_spec.sdf", p1, , , "MINIMUM");
    $sdf_annotate("test_sdf_mtm_spec.sdf", p2, , , "MAXIMUM");
    #10 a = 1;
    #10 $finish;
  end

  always @(y1 or y2) if ($time >= 10) $display("%0d: y1=%b y2=%b", $time, y1, y2);
endmodule

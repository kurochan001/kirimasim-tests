/*
:name: test_sdf_scale_factors
:description: The scale_factors argument of $sdf_annotate multiplies the min, typ and max values by their own factors before one is annotated (IEEE 1800-2023 Section 32.9)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_scale_factors.expected
*/
// IEEE 1800-2023 §32.9: the sixth argument of $sdf_annotate, scale_factors,
// gives a factor for the minimum, typical and maximum values, and with the
// default scale_type, FROM_MTM, each of the three values is multiplied by its
// own factor. With "TYPICAL" chosen by mtm_spec and the factors "1.0:3.0:1.0",
// the triple (1:2:3) annotates 2 * 3 = 6. The module_instance argument is left
// empty, so the annotation is relative to this module. Icarus Verilog 13.0
// rejects an empty module_instance argument and uses only the first two
// arguments of $sdf_annotate. Verilator 5.052 ignores $sdf_annotate and module
// path delays.

`timescale 1ns/1ns

module sdf_scale_cell(output y, input a);
  buf (y, a);
  specify
    (a => y) = 1;
  endspecify
endmodule

module test_sdf_scale_factors;
  reg a = 0;
  wire y;
  integer f;

  sdf_scale_cell u(y, a);

  initial begin
    f = $fopen("test_sdf_scale_factors.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_scale_cell\") (INSTANCE u)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (IOPATH a y (1:2:3))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_scale_factors.sdf", , , , "TYPICAL", "1.0:3.0:1.0");
    #10 a = 1;
    #10 a = 0;
    #10 $finish;
  end

  always @(y) if ($time >= 10) $display("%0d: y=%b", $time, y);
endmodule

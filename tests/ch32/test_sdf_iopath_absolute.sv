/*
:name: test_sdf_iopath_absolute
:description: An IOPATH entry replaces the delay of the matching module path, one value for every transition or a rise and a fall value, and paths not in the SDF file keep their delays (IEEE 1800-2023 Section 32.4.1)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.1 32.3 32.8 32.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_iopath_absolute.expected
*/
// IEEE 1800-2023 §32.4.1: an IOPATH entry annotates the module path between the
// same two ports. §32.8: with two values the first is the rise delay and the
// second the fall delay; a single value is used for every transition. §32.3: a
// path that the SDF file does not mention keeps the delay of its specify block.
// §32.9: without a module_instance argument, the instance names in the file are
// relative to the module that calls $sdf_annotate. The test writes the SDF file
// itself before annotating it.

`timescale 1ns/1ns

module sdf_iopath_cell(output y, output z, output w, input a);
  buf (y, a);
  buf (z, a);
  buf (w, a);
  specify
    (a => y) = 1;
    (a => z) = 1;
    (a => w) = 2;
  endspecify
endmodule

module test_sdf_iopath_absolute;
  reg a = 0;
  wire y, z, w;
  integer f;

  sdf_iopath_cell u(y, z, w, a);

  initial begin
    f = $fopen("test_sdf_iopath_absolute.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_iopath_cell\") (INSTANCE u)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (IOPATH a y (3) (5))");
    $fdisplay(f, "      (IOPATH a z (4))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_iopath_absolute.sdf");
    #10 a = 1;
    #10 a = 0;
    #10 $finish;
  end

  always @(y or z or w) if ($time >= 10) $display("%0d: y=%b z=%b w=%b", $time, y, z, w);
endmodule

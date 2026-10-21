/*
:name: test_sdf_device_primitive_without_paths
:description: A DEVICE entry of an SDF file annotates the primitives that drive the outputs of a cell that has no module paths (IEEE 1800-2023 Section 32.4.1)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.1 28.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_device_primitive_without_paths.expected
*/
// IEEE 1800-2023 §32.4.1, Table 32-1: when the cell instance has no specify
// paths, (DEVICE ...) annotates all primitives that drive its outputs. The
// buf of the cell has no delay of its own; after (DEVICE (2) (6)) it has a
// rise delay of 2 and a fall delay of 6 (28.16). Transitions before time 10
// are not printed.
// Icarus Verilog 13.0 does not read DEVICE entries.

`timescale 1ns/1ns

module sdf_device_gate_cell(output y, input a);
  buf (y, a);
endmodule

module test_sdf_device_primitive_without_paths;
  reg a = 0;
  wire y;
  integer f;

  sdf_device_gate_cell u(y, a);

  initial begin
    f = $fopen("test_sdf_device_primitive_without_paths.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_device_gate_cell\") (INSTANCE u)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (DEVICE (2) (6))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_device_primitive_without_paths.sdf");
    #10 a = 1;
    #10 a = 0;
    #10 $finish;
  end

  always @(y) if ($time >= 10) $display("%0d: y=%b", $time, y);
endmodule

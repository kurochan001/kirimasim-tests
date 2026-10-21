/*
:name: test_sdf_device_all_paths
:description: A DEVICE entry of an SDF file without a port annotates its delays to every module path to the outputs of the cell instance (IEEE 1800-2023 Section 32.4.1)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.1 32.3 30.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_device_all_paths.expected
*/
// IEEE 1800-2023 §32.4.1, Table 32-1: (DEVICE ...) without a port instance
// annotates all specify paths to the outputs of the module instance. The cell
// has the paths a => y and b => y with delay 0; after (DEVICE (3) (5)) both
// have a rise delay of 3 and a fall delay of 5, so y rises 3 after a and falls
// 5 after b. Transitions before time 10 are not printed.
// Icarus Verilog 13.0 does not read DEVICE entries.

`timescale 1ns/1ns

module sdf_device_cell(output y, input a, input b);
  and (y, a, b);
  specify
    (a => y) = 0;
    (b => y) = 0;
  endspecify
endmodule

module test_sdf_device_all_paths;
  reg a = 0, b = 1;
  wire y;
  integer f;

  sdf_device_cell u(y, a, b);

  initial begin
    f = $fopen("test_sdf_device_all_paths.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_device_cell\") (INSTANCE u)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (DEVICE (3) (5))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_device_all_paths.sdf");
    #10 a = 1;
    #10 b = 0;
    #10 $finish;
  end

  always @(y) if ($time >= 10) $display("%0d: y=%b", $time, y);
endmodule

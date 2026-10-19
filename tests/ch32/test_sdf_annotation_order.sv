/*
:name: test_sdf_annotation_order
:description: A later SDF entry or a later $sdf_annotate call overwrites an earlier ABSOLUTE value, and values it does not mention stay as annotated (IEEE 1800-2023 Section 32.6)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.6 32.5 32.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_annotation_order.expected
*/
// IEEE 1800-2023 §32.5: SDF entries are annotated in order, so of two ABSOLUTE
// entries for the same path the second wins: z gets 6, not 5. §32.6: each call
// of $sdf_annotate annotates one file, and values from a later file overwrite
// those from an earlier one: y gets 5 from the first file and then 3 from the
// second. §32.3: the second file does not mention z, which keeps 6.

`timescale 1ns/1ns

module sdf_order_cell(output y, output z, input a);
  buf (y, a);
  buf (z, a);
  specify
    (a => y) = 1;
    (a => z) = 1;
  endspecify
endmodule

module test_sdf_annotation_order;
  reg a = 0;
  wire y, z;
  integer f;

  sdf_order_cell u(y, z, a);

  initial begin
    f = $fopen("test_sdf_annotation_order_1.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_order_cell\") (INSTANCE u)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (IOPATH a y (5))");
    $fdisplay(f, "      (IOPATH a z (5))");
    $fdisplay(f, "      (IOPATH a z (6))))))");
    $fclose(f);
    f = $fopen("test_sdf_annotation_order_2.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_order_cell\") (INSTANCE u)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (IOPATH a y (3))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_annotation_order_1.sdf");
    $sdf_annotate("test_sdf_annotation_order_2.sdf");
    #10 a = 1;
    #10 $finish;
  end

  always @(y or z) if ($time >= 10) $display("%0d: y=%b z=%b", $time, y, z);
endmodule

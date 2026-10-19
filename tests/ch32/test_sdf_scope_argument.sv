/*
:name: test_sdf_scope_argument
:description: The module_instance argument of $sdf_annotate limits the annotation to that part of the design, with instance names in the file relative to it (IEEE 1800-2023 Section 32.9)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.9 32.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_scope_argument.expected
*/
// IEEE 1800-2023 §32.9: the second argument of $sdf_annotate names the scope of
// the annotation, and the SDF file is applied at that level of the hierarchy.
// §32.6: this lets different parts of a design be annotated separately. The
// file names the instance c, which here means p1.c; p2.c, an instance of the
// same cell, keeps its specify delay of 1.

`timescale 1ns/1ns

module sdf_scope_cell(output y, input a);
  buf (y, a);
  specify
    (a => y) = 1;
  endspecify
endmodule

module sdf_scope_wrap(output y, input a);
  sdf_scope_cell c(y, a);
endmodule

module test_sdf_scope_argument;
  reg a = 0;
  wire y1, y2;
  integer f;

  sdf_scope_wrap p1(y1, a);
  sdf_scope_wrap p2(y2, a);

  initial begin
    f = $fopen("test_sdf_scope_argument.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_scope_cell\") (INSTANCE c)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (IOPATH a y (4))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_scope_argument.sdf", p1);
    #10 a = 1;
    #10 $finish;
  end

  always @(y1 or y2) if ($time >= 10) $display("%0d: y1=%b y2=%b", $time, y1, y2);
endmodule

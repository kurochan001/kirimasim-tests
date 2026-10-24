/*
:name: test_sdf_multiple_files_increment_scope
:description: Each $sdf_annotate call annotates one SDF file, whose INCREMENT values modify and ABSOLUTE values overwrite what earlier files annotated, and its second argument selects the part of the design the file applies to (IEEE 1800-2023 Section 32.6)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.6 32.5 32.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_multiple_files_increment_scope.expected
*/
// IEEE 1800-2023 §32.6: more than one SDF file can be annotated, one per call
// of $sdf_annotate; the values of a later file modify (INCREMENT) or
// overwrite (ABSOLUTE) those of earlier files, and the second argument of
// $sdf_annotate selects the region of the design that a file annotates.
// §32.5: INCREMENT adds to the current value and ABSOLUTE replaces it. §32.9:
// instance names in a file are relative to that region.
//
// The cell is a buffer with the path a => y of delay 1, and p1 and p2 each
// contain one instance c of it. The first file, without a region, sets both
// p1.c and p2.c to 4. The second file, annotated in the region p1, adds 2 to
// the path of c, so p1.c has 6. The third file, in the region p2, sets the
// path of c to 3. a rises at 10: y1 follows at 16 and y2 at 13. The test
// creates its SDF files in the current directory.
//
// Icarus Verilog 13.0 applies INCREMENT values as absolute delays.

`timescale 1ns/1ns

module mf_cell (output y, input a);
  buf (y, a);
  specify
    (a => y) = 1;
  endspecify
endmodule

module mf_wrap (output y, input a);
  mf_cell c (y, a);
endmodule

module test_sdf_multiple_files_increment_scope;
  reg a = 0;
  wire y1, y2;
  integer f;

  mf_wrap p1 (y1, a);
  mf_wrap p2 (y2, a);

  initial begin
    f = $fopen("test_sdf_multiple_files_increment_scope_1.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"mf_cell\") (INSTANCE p1.c)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (IOPATH a y (4)))))");
    $fdisplay(f, "  (CELL (CELLTYPE \"mf_cell\") (INSTANCE p2.c)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (IOPATH a y (4))))))");
    $fclose(f);
    f = $fopen("test_sdf_multiple_files_increment_scope_2.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"mf_cell\") (INSTANCE c)");
    $fdisplay(f, "    (DELAY (INCREMENT (IOPATH a y (2))))))");
    $fclose(f);
    f = $fopen("test_sdf_multiple_files_increment_scope_3.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"mf_cell\") (INSTANCE c)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (IOPATH a y (3))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_multiple_files_increment_scope_1.sdf");
    $sdf_annotate("test_sdf_multiple_files_increment_scope_2.sdf", p1);
    $sdf_annotate("test_sdf_multiple_files_increment_scope_3.sdf", p2);
    #10 a = 1;
    #10 $finish;
  end

  always @(y1 or y2) if ($time >= 10) $display("%0d: y1=%b y2=%b", $time, y1, y2);
endmodule

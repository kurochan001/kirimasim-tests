/*
:name: test_sdf_unannotatable_entry_warning
:description: The SDF annotator warns about an IOPATH entry for which the cell has no module path, and still annotates the entries before and after it (IEEE 1800-2023 Section 32.3)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.3 32.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_unannotatable_entry_warning.expected
:expected_stderr_regex: (?i:\bwarn(?:ing)?\b|%Warning-)
*/
// IEEE 1800-2023 §32.3: the SDF annotator shall issue a warning for any data
// it is unable to annotate, and a timing value that the SDF file does not
// provide keeps its value. §32.4.1: an IOPATH entry annotates the module path
// between its two ports.
//
// The cell has buffers from a to y, z and w, and module paths only from a to
// y and from a to z, with delay 1. The SDF file has (IOPATH a y (4)), then
// (IOPATH a w (7)), for which there is no module path, then (IOPATH a z (6)).
// The messages of the run have to contain a warning; y follows a after 4, z
// after 6, and w, which has no path, at once. The test creates its SDF file
// in the current directory.
//
// Icarus Verilog 13.0 reports the entry that it cannot annotate as an error
// ("SDF ERROR"), not as a warning.

`timescale 1ns/1ns

module ua_cell (output y, z, w, input a);
  buf (y, a);
  buf (z, a);
  buf (w, a);
  specify
    (a => y) = 1;
    (a => z) = 1;
  endspecify
endmodule

module test_sdf_unannotatable_entry_warning;
  reg a = 0;
  wire y, z, w;
  integer f;

  ua_cell u (y, z, w, a);

  initial begin
    f = $fopen("test_sdf_unannotatable_entry_warning.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"ua_cell\") (INSTANCE u)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (IOPATH a y (4))");
    $fdisplay(f, "      (IOPATH a w (7))");
    $fdisplay(f, "      (IOPATH a z (6))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_unannotatable_entry_warning.sdf");
    #10 a = 1;
    #10 $finish;
  end

  always @(y or z or w) if ($time >= 10) $display("%0d: y=%b z=%b w=%b", $time, y, z, w);
endmodule

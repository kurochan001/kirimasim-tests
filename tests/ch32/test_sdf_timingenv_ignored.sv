/*
:name: test_sdf_timingenv_ignored
:description: The SDF annotator ignores a TIMINGENV section, which has nothing to annotate in SystemVerilog, without any warning, and annotates the DELAY section that follows it in the same cell (IEEE 1800-2023 Section 32.3)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.3 32.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_timingenv_ignored.expected
:expected_stderr_regex: \A(?![\s\S]*(?i:warn|error))[\s\S]*\Z
*/
// IEEE 1800-2023 §32.3: constructs of an SDF file that are not related to
// SystemVerilog timing, such as everything in the TIMINGENV section, shall be
// ignored without any warning. §32.4.1: an IOPATH entry annotates the module
// path between its two ports.
//
// The cell u has the path a => y with delay 1. Its CELL entry first has a
// TIMINGENV section with a PATHCONSTRAINT and then a DELAY section with
// (IOPATH a y (4)). So y follows a after 4, and the messages of the run
// contain neither a warning nor an error. The test creates its SDF file in
// the current directory.
//
// Icarus Verilog 13.0 reports the TIMINGENV section as an SDF syntax error and
// then does not annotate the DELAY section after it.

`timescale 1ns/1ns

module te_cell (output y, input a);
  buf (y, a);
  specify
    (a => y) = 1;
  endspecify
endmodule

module test_sdf_timingenv_ignored;
  reg a = 0;
  wire y;
  integer f;

  te_cell u (y, a);

  initial begin
    f = $fopen("test_sdf_timingenv_ignored.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"te_cell\") (INSTANCE u)");
    $fdisplay(f, "    (TIMINGENV (PATHCONSTRAINT a y (2) (3)))");
    $fdisplay(f, "    (DELAY (ABSOLUTE (IOPATH a y (4))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_timingenv_ignored.sdf");
    #10 a = 1;
    #10 $finish;
  end

  always @(y) if ($time >= 10) $display("%0d: y=%b", $time, y);
endmodule

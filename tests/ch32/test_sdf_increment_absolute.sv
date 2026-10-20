/*
:name: test_sdf_increment_absolute
:description: SDF entries are applied in order: ABSOLUTE replaces a delay and INCREMENT adds to the current one (IEEE 1800-2023 Section 32.5)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.5 32.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_increment_absolute.expected
*/
// IEEE 1800-2023 §32.5: the entries of an SDF file are annotated in the order
// they appear; an ABSOLUTE entry overwrites the current value and an INCREMENT
// entry modifies it. The path to y is set to 4 and then increased by 2, so its
// delay is 6. The path to z is only increased by 1, from its specify delay of 2
// to 3. Icarus Verilog 13.0 applies the INCREMENT values as absolute delays.
// In Verilator 5.052, $sdf_annotate and module path delays have no effect.

`timescale 1ns/1ns

module sdf_incr_cell(output y, output z, input a);
  buf (y, a);
  buf (z, a);
  specify
    (a => y) = 1;
    (a => z) = 2;
  endspecify
endmodule

module test_sdf_increment_absolute;
  reg a = 0;
  wire y, z;
  integer f;

  sdf_incr_cell u(y, z, a);

  initial begin
    f = $fopen("test_sdf_increment_absolute.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"sdf_incr_cell\") (INSTANCE u)");
    $fdisplay(f, "    (DELAY");
    $fdisplay(f, "      (ABSOLUTE (IOPATH a y (4)))");
    $fdisplay(f, "      (INCREMENT (IOPATH a y (2)) (IOPATH a z (1))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_increment_absolute.sdf");
    #10 a = 1;
    #10 a = 0;
    #10 $finish;
  end

  always @(y or z) if ($time >= 10) $display("%0d: y=%b z=%b", $time, y, z);
endmodule

/*
:name: test_sdf_mtm_and_scale_factors
:description: $sdf_annotate with the mtm_spec MAXIMUM and the scale factors 1.0:1.0:2.0 annotates a path whose SDF triple is 10:20:30 with 60 ns, the maximum value multiplied by the maximum scale factor (IEEE 1800-2023 Section 32.9)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.9 32.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_mtm_and_scale_factors.expected
*/
// IEEE 1800-2023 §32.9: the fourth and fifth arguments of $sdf_annotate that
// follow the config and log file names are the mtm_spec and the scale factors.
// mtm_spec MAXIMUM selects the maximum member of a min/typ/max triple, and the
// scale factors "1.0:1.0:2.0" multiply the minimum by 1.0, the typical by 1.0
// and the maximum by 2.0; the default scale type FROM_MTM applies each factor
// to its own member. The SDF file gives the path from a to y the triple
// 10:20:30, so the annotated delay is 30 * 2.0 = 60 ns. The design changes a
// at 1 ns and records the time y changes, which must be 61 ns.
//
// The SDF file is written by the test itself, because the runners run every
// test in a temporary directory. The file names the instance u below the
// module test_sdf_mtm_and_scale_factors, as the SDF annotation is relative to
// the module instance that the second argument names.

`timescale 1ns/1ns

module sdf_scaled_buf(input a, output y);
  assign y = a;

  specify
    (a => y) = (1);
  endspecify
endmodule

module test_sdf_mtm_and_scale_factors;
  logic a = 0;
  wire y;
  time changed = 0;
  integer fd;

  sdf_scaled_buf u(.a(a), .y(y));

  always @(y) if (y === 1'b1) changed = $time;

  initial begin
    fd = $fopen("test_sdf_mtm_and_scale_factors.sdf", "w");
    $fwrite(fd, "(DELAYFILE (SDFVERSION \"3.0\") (DESIGN \"test_sdf_mtm_and_scale_factors\")");
    $fwrite(fd, " (DATE \"x\") (VENDOR \"x\") (PROGRAM \"x\") (VERSION \"x\")");
    $fwrite(fd, " (DIVIDER /) (TIMESCALE 1ns)\n");
    $fwrite(fd, "(CELL (CELLTYPE \"sdf_scaled_buf\") (INSTANCE u)\n");
    $fwrite(fd, "(DELAY (ABSOLUTE (IOPATH a y (10:20:30) (10:20:30))))))\n");
    $fclose(fd);
    $sdf_annotate("test_sdf_mtm_and_scale_factors.sdf", test_sdf_mtm_and_scale_factors,
                  "", "", "MAXIMUM", "1.0:1.0:2.0", "FROM_MTM");
    #1 a = 1;
    #70 $display("change at 61: %0d", changed == 61);
  end
endmodule

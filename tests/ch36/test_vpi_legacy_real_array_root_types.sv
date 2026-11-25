/*
:name: test_vpi_legacy_real_array_root_types
:description: Distinct VPI representations for the real array root and its elements
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.12.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_vpi_legacy_real_array_root_types
:vpi_c: @test_vpi_legacy_real_array_root_types.c
:expected_stdout: @test_vpi_legacy_real_array_root_types.expected
*/
`timescale 1ns/1ns

module test_vpi_legacy_real_array_root_types;
  real measurements[4:3];
  real calibration;
  integer samples[0:1];
  time ticks[0:1];

  initial begin
    measurements[3] = -0.5;
    measurements[4] = 1.75;
    calibration = 2.25;
    samples[0] = 11;
    ticks[0] = 7;
    #2 $display("hdl=%0.2f,%0.2f,%0.2f,%0d,%0d",
                calibration, measurements[4], measurements[3], samples[0], ticks[0]);
    $finish;
  end
endmodule

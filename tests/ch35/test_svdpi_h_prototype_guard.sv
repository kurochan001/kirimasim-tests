/*
:name: test_svdpi_h_prototype_guard
:description: The DPI header guards its import and export declaration qualifiers
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 I.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_svdpi_h_prototype_guard.c
:expected_stdout: @test_svdpi_h_prototype_guard.expected
*/
module test_svdpi_h_prototype_guard;
  import "DPI-C" function int dpi_prototype_guard_version_available();

  initial $display("DPI version available=%0d", dpi_prototype_guard_version_available());
endmodule

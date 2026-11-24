/*
:name: test_svdpi_h_supplies_empty_default_dpi_extern
:description: The DPI header supplies an empty default declaration qualifier
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 I.3
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_svdpi_h_supplies_empty_default_dpi_extern.expected
:expected_exit: 0
:dpi_c: @test_svdpi_h_supplies_empty_default_dpi_extern.c
*/
module test_svdpi_h_supplies_empty_default_dpi_extern;
  import "DPI-C" function int check_default_dpi_qualifier();

  initial $display("empty default DPI qualifier=%0d", check_default_dpi_qualifier());
endmodule

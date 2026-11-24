/*
:name: test_svdpi_h_uses_application_dpi_extern_in_declarations
:description: The DPI header uses the declaration qualifier supplied by the application
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 I.3
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_svdpi_h_uses_application_dpi_extern_in_declarations.expected
:expected_exit: 0
:dpi_c: @test_svdpi_h_uses_application_dpi_extern_in_declarations.c
*/
module test_svdpi_h_uses_application_dpi_extern_in_declarations;
  import "DPI-C" function int check_application_dpi_qualifier();

  initial $display("application DPI qualifier used=%0d", check_application_dpi_qualifier());
endmodule

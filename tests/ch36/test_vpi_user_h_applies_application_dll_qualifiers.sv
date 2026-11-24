/*
:name: test_vpi_user_h_applies_application_dll_qualifiers
:description: The VPI header uses import and export qualifiers supplied by the application
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.7 K.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_user_h_applies_application_dll_qualifiers.expected
:expected_exit: 0
:vpi_c: @test_vpi_user_h_applies_application_dll_qualifiers.c
*/
module test_vpi_user_h_applies_application_dll_qualifiers;
  initial #1 $finish;
endmodule

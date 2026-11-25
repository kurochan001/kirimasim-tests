/*
:name: test_legacy_dpi_import_compiler_diagnostic
:description: A legacy DPI import tests the migration diagnostic for its packed argument
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_legacy_dpi_import_compiler_diagnostic.expected
*/
module test_legacy_dpi_import_compiler_diagnostic;
  import "DPI" function void dpi_value(input bit [36:0] packed_data);
  initial $display("legacy declaration compiled");
endmodule

/*
:name: test_vpi_dpi_language_and_linkage_name_for_imports_and_exports
:description: VPI reports the DPI language and C linkage name of imported and exported subroutines
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.41 35.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_dpi_language_and_linkage_name_for_imports_and_exports.expected
:vpi_c: @test_vpi_dpi_language_and_linkage_name_for_imports_and_exports.c
*/
module test_vpi_dpi_language_and_linkage_name_for_imports_and_exports;
  import "DPI-C" foreign_increment = function int local_import(input int n);
  import "DPI" legacy_helper = function int legacy_import(input int n);
  export "DPI-C" foreign_export = function local_export;
  export "DPI" legacy_export = function sv_legacy_export;

  function int local_export(input int n);
    return n + 2;
  endfunction

  function int sv_legacy_export(input int n);
    return n + 3;
  endfunction

  initial #1 $display("design completed");
endmodule

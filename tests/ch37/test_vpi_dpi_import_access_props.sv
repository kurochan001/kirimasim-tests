/*
:name: test_vpi_dpi_import_access_props
:description: a DPI-C import declares a task or function whose vpiAccessType is vpiDPIImportAcc and an export one whose vpiAccessType is vpiDPIExportAcc; vpiDPIPure is TRUE only for the pure import and vpiDPIContext only for the context imports (IEEE 1800-2023 Section 37.41)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.41 35.5.2 35.5.3 35.5.4 35.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_dpi_import_access_props.c
:expected_stdout: @test_vpi_dpi_import_access_props.expected
*/
// IEEE 1800-2023 §37.41: vpiAccessType of a task or function is
// vpiDPIImportAcc for a "DPI-C" import and vpiDPIExportAcc for a "DPI-C"
// export (detail 6, 35.5.4, 35.6); vpiDPIPure is TRUE for a pure import
// function (detail 7, 35.5.2) and vpiDPIContext for a context import function
// or task (detail 8, 35.5.3). The plain import function and the export are
// neither pure nor context, and the context imports are not pure. The imports
// are declared in the module and never called; the VPI application defines
// them, so that their linkage names are resolved whatever the tool does with
// imports that are not called. The subroutines are found by name and printed
// in a fixed order.

module test_vpi_dpi_import_access_props;
  import "DPI-C" pure function int vt_dpi_pure(input int a);
  import "DPI-C" context function int vt_dpi_ctx(input int a);
  import "DPI-C" function int vt_dpi_plain(input int a);
  import "DPI-C" context task vt_dpi_ctx_task(input int a);
  export "DPI-C" function sv_exported;

  function int sv_exported(input int a);
    return a + 1;
  endfunction

  initial #1 $vt_dpi;
endmodule

/*
:name: test_vpi_module_binding_properties
:description: vpiLibrary, vpiCell and vpiConfig give the library, cell and config binding of a module instance (IEEE 1800-2023 Section 33.7)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_vpi_module_binding_properties
:vpi_c: @test_vpi_module_binding_properties.c
:expected_stdout: @test_vpi_module_binding_properties.expected
*/
// IEEE 1800-2023 §33.7: an object of type vpiModule has the string properties
// vpiLibrary (the library into which the module was compiled), vpiCell (the
// cell bound to the instance) and vpiConfig (the library.cell name of the
// config controlling the binding). The instance u is bound to work.leaf by the
// config cfg, so its library is work, its cell is leaf and its config binding
// is set. The application prints whether each property has the expected value.

module leaf;
endmodule

module test_vpi_module_binding_properties;
  leaf u();

  initial #1 $vt_report;
endmodule

config cfg;
  design work.test_vpi_module_binding_properties;
  default liblist work;
  instance test_vpi_module_binding_properties.u use work.leaf;
endconfig

/*
:name: test_vpi_module_config_name
:description: vpiConfig of a module instance is the library.cell name of the config that controls its binding, which is the config of a hierarchical config rule for the instances below the instance it configures (IEEE 1800-2023 Section 33.7)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.7 33.4.2 33.4.1.3 33.4.1.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_module_config_name.c
:expected_stdout: @test_vpi_module_config_name.expected
*/
// IEEE 1800-2023 §33.7: an object of type vpiModule has the string property
// vpiConfig, the library.cell name of the config that controls the binding
// of the instance, and vpiCell, the name of the cell bound to it. The config
// cfgv binds this module's u by its default liblist and v, by an instance
// clause, to the cell cfgv_alt (33.4.1.3, 33.4.1.6); both are controlled by
// work.cfgv. It binds m to the config cfgv_sub with :config, so the rules of
// cfgv_sub bind the instances below m (33.4.2): m.leaf becomes a cfgv_alt,
// and its binding is controlled by work.cfgv_sub. The application prints the
// cell and the config of u, v and m.leaf from a cbStartOfSimulation callback.
// The VPI headers of Icarus Verilog 13.0 lack vpiConfig, and Icarus skips
// config declarations.

module cfgv_leaf;
endmodule

module cfgv_alt;
endmodule

module cfgv_mid;
  cfgv_leaf leaf();
endmodule

module test_vpi_module_config_name;
  cfgv_leaf u();
  cfgv_leaf v();
  cfgv_mid m();
endmodule

config cfgv_sub;
  design work.cfgv_mid;
  default liblist work;
  instance cfgv_mid.leaf use work.cfgv_alt;
endconfig

config cfgv;
  design work.test_vpi_module_config_name;
  default liblist work;
  instance test_vpi_module_config_name.v use work.cfgv_alt;
  instance test_vpi_module_config_name.m use work.cfgv_sub:config;
endconfig

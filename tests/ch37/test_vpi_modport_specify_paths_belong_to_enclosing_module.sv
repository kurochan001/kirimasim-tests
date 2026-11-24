/*
:name: test_vpi_modport_specify_paths_belong_to_enclosing_module
:description: Specify paths using modport terminals belong to their enclosing module
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.39 25.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_modport_specify_paths_belong_to_enclosing_module.expected
:expected_exit: 0
:vpi_c: @test_vpi_modport_specify_paths_belong_to_enclosing_module.c
*/
`timescale 1ns/1ns
interface path_interface(input wire source);
  wire sink_a, sink_b;
  modport paths(input source, output sink_a, sink_b);
endinterface

module modport_path_module(path_interface.paths bus);
  assign bus.sink_a = bus.source;
  assign bus.sink_b = bus.source;
  specify
    (bus.source => bus.sink_a) = 3;
    (bus.source => bus.sink_b) = 4;
  endspecify
endmodule

module path_module(input wire source, output wire sink);
  buf transfer(sink, source);
  specify
    (source => sink) = 7;
  endspecify
endmodule

module test_vpi_modport_specify_paths_belong_to_enclosing_module;
  logic source = 0;
  wire module_sink;
  path_interface bus(source);
  modport_path_module modport_cell(bus);
  path_module reference_cell(source, module_sink);

  initial #1 $probe_path_owners;
endmodule

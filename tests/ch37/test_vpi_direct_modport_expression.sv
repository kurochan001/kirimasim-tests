/*
:name: test_vpi_direct_modport_expression
:description: Direct interface and modport expressions on virtual-interface assignment right-hand sides identify different VPI objects
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.29 37.14
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_direct_modport_expression.c
:expected_stdout: @test_vpi_direct_modport_expression.expected
*/
// IEEE 1800-2023 37.29: the interface expression group includes the
// interface and modport objects. Both RHSs directly name elaborated
// objects, so the local port-reference rule does not apply.
`timescale 1ns/1ns
interface direct_modport_bus;
  logic data;
  modport reader(input data);
  modport writer(output data);
endinterface

module test_vpi_direct_modport_expression;
  direct_modport_bus physical();
  virtual direct_modport_bus whole;
  virtual direct_modport_bus.reader view;

  task bind_views;
    whole = physical;
    view = physical.reader;
  endtask

  initial begin
    physical.data = 1'b1;
    bind_views();
    #1 $display("HDL views=%b,%b", whole.data, view.data);
  end
endmodule

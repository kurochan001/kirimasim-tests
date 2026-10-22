/*
:name: test_vpi_interface_modport_links
:description: a modport leads to its interface and an io declaration of a modport to the modport; an interface gives a nested interface, its default clocking block and its continuous assignments and processes, whose vpiInstance is the interface; the declaration of a plain extern task has the extern access type and leads to a task with its argument; a typedef of a specialized virtual interface gives the parameter values, and the element of an array of a modport interface type is a modport typespec (IEEE 1800-2023 Sections 37.7, 37.6, 37.8 and 37.30)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.7 37.6 37.8 37.30 37.13 37.41 37.28 25.5 25.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_interface_modport_links.c
:expected_stdout: @test_vpi_interface_modport_links.expected
*/
// IEEE 1800-2023 §37.7: a modport leads to its interface, so vpi_handle
// (vpiInterface, modport) is the interface instance b, and an io decl of a
// modport leads back to the modport with vpiModport. §37.6: an interface
// iterates the interfaces instantiated in it (nest), its continuous
// assignments and its processes, which lead back to it with vpiInstance, as
// its modports do, and vpiDefaultClocking gives its default clocking block.
// §37.8: an interface tf decl has vpiAccessType vpiForkJoinAcc or
// vpiExternAcc (detail 2), the first for a forkjoin task that several modules
// can export (detail 1, §25.7.4), so the plain extern task ping (§25.7.3) has
// vpiExternAcc; vpiTask leads to a task whose argument k is an input io decl
// (§37.41, §37.13). §37.30 detail 3: the typedef chan5_t of a virtual
// interface type whose parameters DEPTH and FAST are set to 5 and 1 (§25.9)
// is an interface typespec whose vpiDefName is the interface name and whose
// vpiParamAssign iteration gives both values (§37.28); the typedef sink_set_t,
// an unpacked array of the modport type chan.sink, is an array typespec whose
// element typespec is an interface typespec for the modport sink, with
// vpiDefName sink (detail 1) and the property vpiIsModPort TRUE. The lists are
// sorted.

`timescale 1ns/1ns

interface test_vpi_interface_modport_links_inner;
  logic s = 0;
endinterface

interface test_vpi_interface_modport_links_bus;
  logic clk = 0, req = 0, gnt;
  test_vpi_interface_modport_links_inner nest();
  assign gnt = req;
  initial req = 1;
  default clocking cb @(posedge clk);
  endclocking
  extern task ping(input int k);
  modport dev(input req, output gnt, export ping);
  modport host(output req, input gnt);
endinterface

interface test_vpi_interface_modport_links_chan #(parameter int DEPTH = 2, parameter bit FAST = 0);
  logic [DEPTH:0] q;
  logic v;
  modport sink(output v, input q);
endinterface

module test_vpi_interface_modport_links_dev(test_vpi_interface_modport_links_bus.dev d);
  task d.ping(input int k);
  endtask
endmodule

module test_vpi_interface_modport_links;
  typedef virtual test_vpi_interface_modport_links_chan #(.FAST(1), .DEPTH(5)) chan5_t;
  typedef virtual test_vpi_interface_modport_links_chan.sink sink_set_t [3];

  test_vpi_interface_modport_links_bus b();
  test_vpi_interface_modport_links_dev u(b.dev);

  initial #1 $vt_links;
endmodule

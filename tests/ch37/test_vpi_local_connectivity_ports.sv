/*
:name: test_vpi_local_connectivity_ports
:description: The local load and driver iterations of a net inside a module return the connected ports and nothing from outside the module: an input port is a driver, an output port is a load, and an inout port is both (IEEE 1800-2023 Section 37.16)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.16 23.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_local_connectivity_ports.c
:expected_stdout: @test_vpi_local_connectivity_ports.expected
*/
// IEEE 1800-2023 §37.16 detail 17: vpiLocalLoad and vpiLocalDriver return only
// the loads or drivers that are local, i.e., contained by the module instance
// that contains the net, including any ports connected to the net; output and
// inout ports are loads, input and inout ports are drivers. The top-level
// continuous assignment to the net a that is connected to the input port of
// u is outside u, so it is not in the local driver set of the port's net.
// Each set is printed sorted by name.

`timescale 1ns/1ns

module lc_cell(input wire i, output wire o, inout wire io);
  wire n;
  assign n = i;
  assign o = n;
endmodule

module test_vpi_local_connectivity_ports;
  wire a, b, c;

  assign a = 1'b1;

  lc_cell u(a, b, c);

  initial #1 $vt_local;
endmodule

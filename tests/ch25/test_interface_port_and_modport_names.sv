/*
:name: test_interface_port_and_modport_names
:description: An interface, a modport of that interface and an interface port of a module are named by identifiers; the module reads a variable of the interface through the modport, and a typedef reaches a type declared in the interface through the port name, which gives the width 32 (IEEE 1800-2023 Sections 25.3 and 25.5 and 6.18)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3 25.5 6.18 A.9.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_port_and_modport_names.expected
*/
// IEEE 1800-2023 A.9.3: an interface identifier, a modport identifier and an
// interface port identifier are identifiers. §25.3: a module port can be an
// interface with a modport, here ip_ifc.mp bus. §25.5: the port gives the
// module access to the interface variables and types through that modport, so
// the module reads bus.d. §6.18: the typedef in the module names the type of
// the interface, bus.ifc_int, which is an int and 32 bits wide. The interface
// variable d is 4'h7 when the module reads it at time 1.
//
// Icarus Verilog 13.0 has no interface ports; Verilator 5.052 produces this
// output.

`timescale 1ns/1ns

interface ip_ifc (input logic clk);
  logic [3:0] d;
  typedef int ifc_int;
  modport mp (input d, clk);
endinterface

module ip_user (ip_ifc.mp bus);
  typedef bus.ifc_int bus_int;

  initial #1 $display("iport %0d %0d", $bits(bus_int), bus.d);
endmodule

module test_interface_port_and_modport_names;
  logic clk = 0;
  ip_ifc bus (clk);
  ip_user u (bus);

  initial begin
    bus.d = 4'h7;
    #3 $display("done %h", bus.d);
  end
endmodule

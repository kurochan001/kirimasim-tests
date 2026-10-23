/*
:name: test_vpi_port_kinds_connections
:description: Ports give vpiPortType from their formal (port, interface port, modport port), vpiConnByName and vpiExplicitName, vpiScalar and vpiVector from their own width whatever the width of the actual, their instance, module and typespec, the high connection in the parent and the low connection in the module (a ref obj for an interface port), and a vector port iterates its port bits, whose parent is the port (IEEE 1800-2023 Section 37.14)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.14 37.15 23.2.2 23.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_port_kinds_connections.c
:expected_stdout: @test_vpi_port_kinds_connections.expected
*/
// IEEE 1800-2023 §37.14: port and port bit are the members of the ports
// group. vpiPortType is vpiPort, vpiInterfacePort or vpiModportPort and
// follows the formal (detail 1). vpiConnByName tells whether the instance
// connects the port by name, vpiExplicitName whether the port is written as
// .p(q). vpiHighConn is the connection closer to the top module and vpiLowConn
// the one inside the module (details 3, 4); the low connection of an interface
// port is always a ref obj (detail 5). vpiScalar and vpiVector say whether the
// port itself has one bit or more, not what is connected (detail 6): x has one
// bit and is connected to the 2-bit two, w has three and is connected to the
// 1-bit s1 (23.3.2 extends or truncates the values). A port has one-to-one
// relations to its instance, its module and its typespec, and vpiBit gives its
// port bits, each of which gives the port back through vpiParent. §37.15: the
// high connection of an interface or modport port is a ref obj whose vpiActual
// is the interface or the modport. The application prints the ports of each
// instance in the order of vpiPortIndex.

interface pkc_if;
  logic s;
  modport mp (input s);
endinterface

module pkc_ansi (input logic [3:0] a, output logic y, pkc_if ip, pkc_if.mp mpp);
  assign y = a[0];
endmodule

module pkc_nonansi (x, .p(q), w);
  input x;
  input q;
  input [2:0] w;
endmodule

module test_vpi_port_kinds_connections;
  logic [3:0] n4 = 4'h3;
  logic ny;
  logic [1:0] two = 2'b10;
  logic sq = 1'b0;
  logic s1 = 1'b1;

  pkc_if i0();
  pkc_ansi ua (.a(n4), .y(ny), .ip(i0), .mpp(i0.mp));
  pkc_nonansi un (two, sq, s1);

  initial #1 $vt_ports;
endmodule

/*
:name: test_vpi_ports
:description: The ports of an instance give their index, name, explicit name, direction, size, scalar or vector, and the connections above and below them, with NULL for an unconnected port and for a null port (IEEE 1800-2023 Section 37.14)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.14 23.2.2.1 23.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_ports.c
:expected_stdout: @test_vpi_ports.expected
*/
// IEEE 1800-2023 §37.14: vpi_iterate(vpiPort, instance) gives the ports.
// vpiPortIndex gives their order from 0 (detail 9). vpiName is the explicit
// name of a port where there is one, as for .p(q), otherwise its own name, and
// NULL when it has none (detail 8). vpiDirection, vpiSize, vpiScalar and
// vpiVector describe the port itself (detail 6). vpiHighConn is the connection
// in the instantiating module and vpiLowConn the one inside the module (details
// 3, 4); vpiHighConn is NULL for nc, which the instance leaves unconnected, and
// for the null port between a and y both connections are NULL and vpiSize is 0
// (details 10, 11). The application sorts the ports by index.

module pt_sub(a, , y, z, nc, .p(q));
  input [3:0] a;
  output y;
  inout z;
  input nc;
  input q;
  assign y = ^a ^ q;
endmodule

module test_vpi_ports;
  logic [3:0] av = 4'h3;
  logic qv = 1'b1;
  wire yw, zw;

  pt_sub u(.a(av), .y(yw), .z(zw), .p(qv));

  initial #1 $vt_ports;
endmodule

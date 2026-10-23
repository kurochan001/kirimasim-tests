/*
:name: test_vpi_net_ports_portinst_bits
:description: vpiPorts of a net gives the port whose low connection it is and of a net bit the port bit; vpiPortInst of a net gives the instance port it is connected to, of a net bit the port bit, or the whole port when the bit cannot be placed in a complex high connection, of a scalar net the scalar port, and nothing for a bit that a size mismatch leaves unconnected; vpiLowConn and vpiHighConn of the ports give the nets back (IEEE 1800-2023 Section 37.16)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.16 37.14 23.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_net_ports_portinst_bits.c
:expected_stdout: @test_vpi_net_ports_portinst_bits.expected
*/
// IEEE 1800-2023 §37.16: a net has one-to-many relations to the ports whose
// low connection it is (vpiPorts) and to the instance ports whose high
// connection it is part of (vpiPortInst), and a port has vpiLowConn and
// vpiHighConn to nets. For vpiPorts, a net bit gives port bits and a whole net
// gives the whole port (detail 6). For vpiPortInst, a bit or scalar gives port
// bits or scalar ports, except that it gives the whole port when the high
// connection is a complex expression in which the bit index cannot be
// determined, such as the sum tc + 2'b01 on cx, and a whole net gives the
// whole port (detail 7). A net that is part of the high connection but not
// connected to any bit of the port, because of a size mismatch, gives no port
// (detail 8): the 4-bit tw is connected to the 2-bit input v, so only tw[1:0]
// reach it (23.3.3: the connection is an assignment, which truncates). The
// application prints the kind of each object returned, with the port of a
// port bit.

module npp_mod (input wire [1:0] v, input wire s, input wire [1:0] cx);
endmodule

module test_vpi_net_ports_portinst_bits;
  wire [3:0] tw;
  wire ts;
  wire [1:0] tc;

  npp_mod u (.v(tw), .s(ts), .cx(tc + 2'b01));

  initial #1 $vt_ports;
endmodule

/*
:name: test_illegal_interface_port_connected_to_net
:description: An interface port has to be connected to an interface instance or an interface port, so it cannot be connected to a net (IEEE 1800-2023 Section 23.3.3.4)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.3.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the interface port bus of u is connected to the net w, which is not an interface instance or interface port
:expected_stderr_regex: test_illegal_interface_port_connected_to_net\.sv:31:
*/
// IEEE 1800-2023 §23.3.3.4: an interface port shall always be connected
// to an interface instance or to an interface port of a higher level
// module. u connects its port bus, of the interface type link_net_if, to
// the net w; connecting the instance ifc would be legal.
// Icarus Verilog 13.0 does not support the interface port declaration and
// stops with a syntax error there.

interface link_net_if;
  logic x;
endinterface

module interface_port_to_net_user(link_net_if bus);
endmodule

module test_illegal_interface_port_connected_to_net;
  link_net_if ifc();
  wire w;
  interface_port_to_net_user u(w);   // illegal
endmodule

/*
:name: test_illegal_interface_port_unconnected
:description: An interface port cannot be left unconnected (IEEE 1800-2023 Section 23.3.3.4)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.3.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the interface port of u is not connected
:expected_stderr_regex: test_illegal_interface_port_unconnected\.sv:26:
*/
// IEEE 1800-2023 §23.3.3.4: an interface port instance shall always be
// connected to an interface instance or a higher-level interface port; it
// cannot be left unconnected.

interface link_if;
  logic x;
endinterface

module user(link_if bus);
endmodule

module test_illegal_interface_port_unconnected;
  user u();            // illegal: bus is not connected
endmodule

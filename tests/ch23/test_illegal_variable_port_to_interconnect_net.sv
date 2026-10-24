/*
:name: test_illegal_variable_port_to_interconnect_net
:description: A port declared as a variable cannot be connected to an interconnect net (IEEE 1800-2023 Section 23.3.3.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the input port p of u is a variable and is connected to the interconnect net link
:expected_stderr_regex: test_illegal_variable_port_to_interconnect_net\.sv:37:
*/
// IEEE 1800-2023 §23.3.3.2: it is illegal to connect a port variable to an
// interconnect net. The input port p of vin_sink is declared with var, so it
// is a variable, and the instance u connects it to the interconnect net link.
// The instance src connects link to its wire output, so link gets the net
// type wire at the end of elaboration (23.3.3.7.1) and breaks no other rule;
// the instance n connects link to a wire input port, which is legal.
// Oracle checks: Icarus Verilog 13.0 and the 5.052 release of Verilator do not
// support interconnect nets and stop at the declaration of link.

module vin_source(output wire o);
  assign o = 1'b1;
endmodule

module vin_net_sink(input wire p);
endmodule

module vin_sink(input var logic p);
endmodule

module test_illegal_variable_port_to_interconnect_net;
  interconnect link;
  vin_source src (.o(link));
  vin_net_sink n (.p(link));
  vin_sink u (.p(link));   // illegal: variable port on an interconnect net
endmodule

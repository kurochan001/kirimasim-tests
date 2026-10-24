/*
:name: test_illegal_variable_port_to_interconnect_port
:description: A port declared as a variable cannot be connected to an interconnect port of the instantiating module (IEEE 1800-2023 Section 23.3.3.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable input port p of the instance u in vip_mid is connected to the interconnect port ip of vip_mid
:expected_stderr_regex: test_illegal_variable_port_to_interconnect_port\.sv:31:
*/
// IEEE 1800-2023 §23.3.3.2: it is illegal to connect a port variable to an
// interconnect port. vip_mid declares its input ip as an interconnect port
// and passes it to the instance u of vip_sink, whose port p is declared with
// var and so is a variable. The top connects ip to the wire w, which gives
// the merged net the type wire (23.3.3.7.1), and the instance n inside
// vip_mid connects ip to a wire port, which is legal.
// Oracle checks: Icarus Verilog 13.0 and the 5.052 release of Verilator do not
// support interconnect ports and stop at the header of vip_mid.

module vip_net_sink(input wire p);
endmodule

module vip_sink(input var logic p);
endmodule

module vip_mid(input interconnect ip);
  vip_net_sink n (.p(ip));
  vip_sink u (.p(ip));   // illegal: variable port on an interconnect port
endmodule

module test_illegal_variable_port_to_interconnect_port;
  wire w = 1'b1;
  vip_mid m (.ip(w));
endmodule

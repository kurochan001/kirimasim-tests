/*
:name: test_illegal_port_list_for_module_without_ports
:description: A list of port connections can be given only for a module defined with ports, so an instance of a portless module that connects an expression is an error (IEEE 1800-2023 Section 23.3.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance u2 gives the port connection s to portless_leaf, which is defined without ports
:expected_stderr_regex: test_illegal_port_list_for_module_without_ports\.sv:26:
*/
// IEEE 1800-2023 §23.3.2: the list of port connections shall be provided
// only for modules defined with ports. portless_leaf has no ports; its
// instance u1 has empty parentheses and is legal, and u2 gives one
// connection by order.

module portless_leaf;
  initial $display("%m");
endmodule

module test_illegal_port_list_for_module_without_ports;
  logic s = 1'b0;
  portless_leaf u1();
  portless_leaf u2(s);  // illegal: portless_leaf has no ports
endmodule

/*
:name: test_illegal_net_type_reg_in_port_declaration
:description: In a port declaration, the net type keyword tri cannot be followed directly by the keyword reg (IEEE 1800-2023 Section 6.7.1)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.7.1 23.2.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the output port y is declared with reg right after the net type tri
:expected_stderr_regex: test_illegal_net_type_reg_in_port_declaration\.sv:23:
*/
// IEEE 1800-2023 §6.7.1: the lexical restriction on reg holds for port
// declarations as well as for net declarations: a net type keyword shall not
// be followed directly by reg. The port y of the child writes reg right after
// tri; the port a, with the data type logic after wire, is legal, and so is
// the rest of the design.
// Oracle checks: Icarus Verilog 13.0 and the 5.052 release accept the design.

module test_illegal_net_type_reg_in_port_declaration_child (
  input wire logic a,
  output tri reg y   // illegal: reg right after tri
);
  assign y = a;
endmodule

module test_illegal_net_type_reg_in_port_declaration;
  logic a = 1'b1;
  wire y;
  test_illegal_net_type_reg_in_port_declaration_child c(.a(a), .y(y));
endmodule

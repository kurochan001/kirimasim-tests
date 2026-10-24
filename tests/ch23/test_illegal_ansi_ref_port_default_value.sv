/*
:name: test_illegal_ansi_ref_port_default_value
:description: Only an input port can have a default value and only a variable output port an initial value, so a ref port written with = and a value is an error (IEEE 1800-2023 Sections 23.2.2.2 and 23.2.2.4)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.2.2 23.2.2.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the ref port r of ref_default is given the value 3 in its declaration, and a ref port is neither an input port nor a variable output port
:expected_stderr_regex: test_illegal_ansi_ref_port_default_value\.sv:24:
*/
// IEEE 1800-2023 §23.2.2.2 (footnote 2 of Syntax 23-4): it shall be illegal
// to initialize a port that is not a variable output port or to give a
// default value to a port that is not an input port; §23.2.2.4: defaults
// can be given only for input ports. The port r of ref_default is a ref
// port of type int, which is legal by itself, followed by = 3. The input
// k has a legal default.
// Icarus Verilog 13.0 does not support ref ports, and Verilator 5.052
// reports a default value on a ref port as unsupported; neither error
// comes from this rule.

module ref_default(ref int r = 3, input var int k = 1);  // illegal: r
endmodule

module test_illegal_ansi_ref_port_default_value;
  int v = 7;
  ref_default u(.r(v), .k(2));
endmodule

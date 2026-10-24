/*
:name: test_illegal_nonansi_port_without_port_declaration
:description: Each identifier in the non-ANSI port list of a module has to be declared in the module body as input, output, inout, ref or interface port, and a net declaration alone is not enough (IEEE 1800-2023 Section 23.2.2.1)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.2.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: y is in the port list of nonansi_missing_direction and is declared as a net, but no input, output, inout, ref or interface port declaration declares it
:expected_stderr_regex: test_illegal_nonansi_port_without_port_declaration\.sv:(22|24):
*/
// IEEE 1800-2023 §23.2.2.1: every port_identifier in a port_expression of
// the list of ports shall also be declared in the module body by a port
// declaration (input, output, inout, ref or an interface port), in
// addition to any net or variable declaration of it. In
// nonansi_missing_direction, a has an input declaration; y has only a net
// declaration. A tool can report the error at the port list or at the
// declaration of the net.

module nonansi_missing_direction(a, y);  // illegal: y has no port declaration
  input a;
  wire y;  // or here
  assign y = a;
endmodule

module test_illegal_nonansi_port_without_port_declaration;
  wire p = 1'b1;
  wire q;
  nonansi_missing_direction u(p, q);
endmodule

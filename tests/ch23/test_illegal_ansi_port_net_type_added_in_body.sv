/*
:name: test_illegal_ansi_port_net_type_added_in_body
:description: An ANSI port declaration describes the port completely, so a net declaration in the module body that only adds the net type to a port of the header is an error, although the same pair is legal in the non-ANSI style (IEEE 1800-2023 Section 23.2.2.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.2.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the port a, declared as input [3:0] in the ANSI list of port declarations of ansi_net_added, is declared again in the module body by the net declaration wire [3:0] a
:expected_stderr_regex: test_illegal_ansi_port_net_type_added_in_body\.sv:32:
*/
// IEEE 1800-2023 §23.2.2.2: each declaration of an ANSI list of port
// declarations gives the complete information about the port, and the port
// identifier shall not be redeclared, in part or in full, in the module
// body. The port a of ansi_net_added is declared input [3:0] without a net
// type; its body then declares wire [3:0] a, with the same range, which adds
// only the net type. In the non-ANSI style that is a legal second
// declaration of a port declared without a net type (23.2.2.1), as the
// module nonansi_net_added shows; in the ANSI style it redeclares the port in
// part, and it is the only error.

module nonansi_net_added(a, y);
  input [3:0] a;
  output [3:0] y;
  wire [3:0] a;
  assign y = ~a;
endmodule

module ansi_net_added(input [3:0] a, output logic [3:0] y);
  wire [3:0] a;  // illegal: a is declared in the header
  assign y = a;
endmodule

module test_illegal_ansi_port_net_type_added_in_body;
  wire [3:0] p = 4'h5;
  wire [3:0] q, r;
  nonansi_net_added u0(p, q);
  ansi_net_added u1(p, r);
endmodule

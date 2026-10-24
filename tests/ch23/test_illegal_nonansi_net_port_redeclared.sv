/*
:name: test_illegal_nonansi_net_port_redeclared
:description: A non-ANSI port declaration that includes a net type declares the port completely, so declaring the port again in a net declaration, here to add signed, is an error (IEEE 1800-2023 Section 23.2.2.1)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.2.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the port a is declared as input wire [3:0], which includes a net type, and is declared again by the net declaration wire signed [3:0] a
:expected_stderr_regex: test_illegal_nonansi_net_port_redeclared\.sv:26:
*/
// IEEE 1800-2023 §23.2.2.1: if a port declaration includes a net or
// variable type, the port is completely declared, and declaring it again
// in a net or variable declaration is an error; so the signedness and the
// range have to be in the port declaration itself. The port a of
// nonansi_net_redeclared is declared with the net type wire and then again
// as a signed net. The port b, declared without a net type, legally gets
// its net declaration separately.

module nonansi_net_redeclared(a, b, y);
  input wire [3:0] a;
  input [3:0] b;
  output wire [3:0] y;
  wire signed [3:0] a;  // illegal: a is already completely declared
  wire [3:0] b;
  assign y = a ^ b;
endmodule

module test_illegal_nonansi_net_port_redeclared;
  wire [3:0] p = 4'h3;
  wire [3:0] q = 4'h5;
  wire [3:0] r;
  nonansi_net_redeclared u(p, q, r);
endmodule

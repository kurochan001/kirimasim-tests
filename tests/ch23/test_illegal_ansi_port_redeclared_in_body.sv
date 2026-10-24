/*
:name: test_illegal_ansi_port_redeclared_in_body
:description: An ANSI port declaration describes the port completely, so the port identifier cannot be declared again in the module body (IEEE 1800-2023 Section 23.2.2.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.2.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the port q, declared in the ANSI list of port declarations of ansi_redeclared, is declared again as a variable in the module body
:expected_stderr_regex: test_illegal_ansi_port_redeclared_in_body\.sv:21:
*/
// IEEE 1800-2023 §23.2.2.2: each declaration in an ANSI list of port
// declarations gives the complete information about the port, and the port
// identifier shall not be redeclared, in part or in full, in the module
// body. The body of ansi_redeclared declares q, an output of the header,
// again as a variable of the same type.

module ansi_redeclared(input logic [3:0] d, output logic [3:0] q);
  logic [3:0] q;  // illegal: q is declared in the header
  assign q = d;
endmodule

module test_illegal_ansi_port_redeclared_in_body;
  logic [3:0] d = 4'h9;
  wire [3:0] q;
  ansi_redeclared u(.d(d), .q(q));
endmodule

/*
:name: test_illegal_nonansi_input_port_default
:description: Default port values can be given only in ANSI style declarations, so a non-ANSI input declaration with a value is an error (IEEE 1800-2023 Section 23.2.2.4)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.2.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the non-ANSI input declaration of a in nonansi_default gives it the default 4'h1
:expected_stderr_regex: test_illegal_nonansi_input_port_default\.sv:25:
*/
// IEEE 1800-2023 §23.2.2.4: a default value can be specified only for an
// input port and only in an ANSI style declaration. nonansi_default
// declares its ports in the non-ANSI style, and its input declaration of a
// gives a default. The module ansi_default_ok shows the legal form.
// The design is accepted by Verilator 5.052.

module ansi_default_ok(input logic [3:0] a = 4'h1, output logic [3:0] y);
  assign y = a;
endmodule

module nonansi_default(a, y);
  input [3:0] a = 4'h1;  // illegal: default in a non-ANSI declaration
  output [3:0] y;
  assign y = a;
endmodule

module test_illegal_nonansi_input_port_default;
  wire [3:0] p = 4'h2;
  wire [3:0] q, r;
  ansi_default_ok u0(.y(q));
  nonansi_default u1(p, r);
endmodule

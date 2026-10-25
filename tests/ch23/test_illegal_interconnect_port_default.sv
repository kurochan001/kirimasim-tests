/*
:name: test_illegal_interconnect_port_default
:description: A default value cannot be given for an interconnect port, so an ANSI input port declared interconnect with a value is an error (IEEE 1800-2023 Section 23.2.2.4)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.2.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the input port a of ic_default is declared as an interconnect port and given a default value
:expected_stderr_regex: test_illegal_interconnect_port_default\.sv:27:
*/
// IEEE 1800-2023 §23.2.2.4: a default shall not be specified for a port
// declared as interconnect. The input a of ic_default is an interconnect
// port with a default; the input b, of type logic, has a legal one. The
// interconnect port passes on to a child that reads it, and the instance
// connects it to a net.
// Icarus Verilog 13.0 and Verilator 5.052 reject this line because they do
// not support interconnect ports at all, also without a default, so their
// errors do not come from this rule.

module ic_reader(input wire [3:0] i, output wire [3:0] o);
  assign o = i;
endmodule

module ic_default(input interconnect [3:0] a = 4'h0,  // illegal: interconnect
                  input logic b = 1'b0,
                  output wire [3:0] y);
  ic_reader r(.i(a), .o(y));
endmodule

module test_illegal_interconnect_port_default;
  wire [3:0] n = 4'h6;
  wire [3:0] y;
  ic_default u(.a(n), .b(1'b1), .y(y));
endmodule

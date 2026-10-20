/*
:name: test_illegal_default_nettype_none_port
:description: With `default_nettype none, an undeclared name in a port connection is an error (IEEE 1800-2023 Section 22.8)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.8 6.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: n is not declared and `default_nettype none forbids an implicit net
:expected_stderr_regex: test_illegal_default_nettype_none_port\.sv:25:
*/
// IEEE 1800-2023 §22.8, §6.10: a name used only in a port connection would
// become an implicit net, but `default_nettype none forbids implicit nets. n is
// not declared.

`default_nettype none
module sub(input wire a, output wire y);
  assign y = a;
endmodule

module test_illegal_default_nettype_none_port;
  wire x = 1'b0;
  sub u(.a(x), .y(n));   // illegal: n is not declared
endmodule
`default_nettype wire

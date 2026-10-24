/*
:name: test_illegal_user_nettype_assignment_two_delays
:description: a continuous assignment to a net of a user-defined nettype can have only a single delay (IEEE 1800-2023 Section 10.3.3)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the continuous assignment to bn_bad, a net of the user-defined nettype byte_net, gives the two delays (1, 2)
:expected_stderr_regex: test_illegal_user_nettype_assignment_two_delays\.sv:34:
*/
// IEEE 1800-2023 §10.3.3: up to three delays can be given for a continuous
// assignment to a vector net of a built-in net type, but only a single delay
// for one to a net of a user-defined nettype, used for any value change.
// The wire w2 with two delays and bn_ok with one delay are legal; bn_bad of
// the user-defined nettype has two.
// Icarus Verilog 13.0 gives a syntax error at the nettype declaration, and
// the 5.052 release of Verilator reports nettype as unsupported, so neither
// error counts.

`timescale 1ns/1ns

nettype logic [7:0] byte_net;

module test_illegal_user_nettype_assignment_two_delays;
  logic [7:0] d = 8'h1;
  wire [7:0] w2;
  byte_net bn_ok, bn_bad;

  assign #(1, 2) w2 = d;
  assign #2 bn_ok = d;
  assign #(1, 2) bn_bad = d;   // illegal: two delays for a user-defined nettype

  initial #5 $display("%h %h", w2, bn_ok);
endmodule

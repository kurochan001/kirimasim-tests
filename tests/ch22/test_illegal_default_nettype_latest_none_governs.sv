/*
:name: test_illegal_default_nettype_latest_none_governs
:description: When several `default_nettype directives appear, the latest one controls the implicit nets, so after `default_nettype wire and then `default_nettype none an undeclared net is an error (IEEE 1800-2023 Section 22.8)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.8
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the latest `default_nettype before the module is none, so the undeclared y_implicit, which would otherwise be an implicit net, is an error
:expected_stderr_regex: test_illegal_default_nettype_latest_none_governs\.sv:36:
*/
// IEEE 1800-2023 §22.8: several `default_nettype directives are allowed,
// and the latest one in the source controls the net type of implicit
// nets; after none every net has to be declared. The file first sets wire,
// under which the module nettype_latest_wire_child legally uses an
// implicit net, and then sets none. In the module that follows, the
// undeclared y_implicit on the left of a continuous assignment is
// therefore an error. A tool that kept the first directive, wire, would
// make y_implicit an implicit wire and accept the design.

`default_nettype wire

module nettype_latest_wire_child(input wire a, output wire y);
  assign n_implicit = a;
  assign y = n_implicit;
endmodule

`default_nettype none

module test_illegal_default_nettype_latest_none_governs;
  wire a = 1'b1;
  wire y;
  nettype_latest_wire_child u(.a(a), .y(y));
  assign y_implicit = a;  // illegal: no implicit net under none
endmodule

`default_nettype wire

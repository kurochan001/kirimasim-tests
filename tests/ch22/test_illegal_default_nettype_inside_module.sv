/*
:name: test_illegal_default_nettype_inside_module
:description: The `default_nettype directive can be used only outside design elements, so a `default_nettype between the items of a module is an error (IEEE 1800-2023 Section 22.8)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: `default_nettype appears inside the module test_illegal_default_nettype_inside_module, which is a design element
:expected_stderr_regex: test_illegal_default_nettype_inside_module\.sv:25:
*/
// IEEE 1800-2023 §22.8: `default_nettype can be used only outside design
// elements. The directives before and after the module are legal; the one
// between the two declarations of the module is the only error. Every net
// of the module is declared, so the net type the directive names does not
// matter.
// The design is accepted by Verilator 5.052.

`default_nettype wire

module test_illegal_default_nettype_inside_module;
  wire a = 1'b0;
`default_nettype none  // illegal: inside the module
  wire b = 1'b1;
endmodule

`default_nettype wire

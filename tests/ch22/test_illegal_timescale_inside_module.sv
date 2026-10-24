/*
:name: test_illegal_timescale_inside_module
:description: The `timescale directive is illegal inside a design element, so a `timescale between the items of a module is an error (IEEE 1800-2023 Section 22.7)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: `timescale appears inside the module test_illegal_timescale_inside_module, which is a design element
:expected_stderr_regex: test_illegal_timescale_inside_module\.sv:23:
*/
// IEEE 1800-2023 §22.7: `timescale shall not be specified within a design
// element. The first `timescale, before the module, is legal; the second
// one stands between two items of the module and is the only error.
// The design is accepted by Verilator 5.052.

`timescale 1ns / 1ps

module test_illegal_timescale_inside_module;
  logic a = 1'b0;
`timescale 10ns / 1ns  // illegal: inside the module
  logic b = 1'b1;
endmodule

/*
:name: test_illegal_unconnected_drive_inside_module
:description: an unconnected_drive directive is placed inside a module (IEEE 1800-2023 Section 22.9)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.9
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the `unconnected_drive directive appears inside the module t
:expected_stderr_regex: test_illegal_unconnected_drive_inside_module\.sv:19:
*/
// The unconnected_drive and nounconnected_drive directives shall be
// specified outside the design element declarations. This one is inside
// the module t.

module t;
  `unconnected_drive pull1   // illegal: inside a module
  logic a;
endmodule

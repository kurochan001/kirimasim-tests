/*
:name: test_illegal_resetall_inside_module
:description: The `resetall directive is illegal inside a design element, so a `resetall between the items of a module is an error (IEEE 1800-2023 Section 22.3)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: `resetall appears inside the module test_illegal_resetall_inside_module, which is a design element
:expected_stderr_regex: test_illegal_resetall_inside_module\.sv:24:
*/
// IEEE 1800-2023 §22.3: `resetall shall not be given inside a design element
// (module, program, interface, checker, package, primitive or configuration,
// 3.2). The module below has a `resetall between two of its items; the same
// directive before the module, outside any design element, is
// legal and is not reported.

`resetall

module test_illegal_resetall_inside_module;
  logic a = 1'b0;
`resetall
  logic b = 1'b1;
endmodule

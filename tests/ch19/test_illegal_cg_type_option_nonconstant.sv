/*
:name: test_illegal_cg_type_option_nonconstant
:description: a type option is initialized with a covergroup argument (IEEE 1800-2023 Section 19.7.1)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: type_option.weight is set from the formal w, which is not a constant expression
:expected_stderr_regex: test_illegal_cg_type_option_nonconstant\.sv:25:
*/
// A type option can only be initialized with a constant expression,
// because different instances of a covergroup cannot assign different
// values to its type options. The formal w is not constant.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

module test_illegal_cg_type_option_nonconstant;
  covergroup cg(int w);
    type_option.weight = w;   // illegal: not a constant expression
    coverpoint 0;
  endgroup
endmodule

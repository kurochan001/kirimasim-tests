/*
:name: test_illegal_cg_point_type_string
:description: a coverpoint declares a string data type (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the coverpoint declares the data type string, which is neither integral nor real
:expected_stderr_regex: test_illegal_cg_point_type_string\.sv:24:
*/
// A coverpoint data type, whether written or inferred, shall be an
// integral or real type. The coverpoint bad here declares string.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

module test_illegal_cg_point_type_string;
  covergroup cg(input int v);
    string bad: coverpoint v;   // illegal: not integral or real
  endgroup
endmodule

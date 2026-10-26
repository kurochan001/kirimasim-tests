/*
:name: test_illegal_cg_duplicate_option
:description: the same covergroup option is assigned twice in one definition (IEEE 1800-2023 Section 19.7)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: option.weight is assigned 1 and then 2 in the definition of cg
:expected_stderr_regex: test_illegal_cg_duplicate_option\.sv:25:
*/
// Specifying a value for the same option more than once within the same
// covergroup definition is an error.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

module test_illegal_cg_duplicate_option;
  covergroup cg(input int v);
    option.weight = 1;
    option.weight = 2;   // illegal: the same option twice
    coverpoint v;
  endgroup
endmodule

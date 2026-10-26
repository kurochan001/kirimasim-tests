/*
:name: test_illegal_cg_real_wildcard
:description: a wildcard bin is declared on a real coverpoint (IEEE 1800-2023 Section 19.5.4)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the bin of the real coverpoint r is a wildcard bin, which real coverpoints do not allow
:expected_stderr_regex: test_illegal_cg_real_wildcard\.sv:26:
*/
// A wildcard bin treats x and z positions of its value list specially,
// which a real value cannot have; real coverpoint bins shall not use
// the wildcard keyword.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

module test_illegal_cg_real_wildcard;
  covergroup cg(input real r);
    coverpoint r {
      wildcard bins b = {1.0};   // illegal: wildcard on a real
    }
  endgroup
endmodule

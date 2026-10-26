/*
:name: test_illegal_cg_matches_zero
:description: a cross bin matches clause uses zero as its policy (IEEE 1800-2023 Section 19.6.1.2)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.6.1.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the matches clause gives 0, but its expression shall be a positive integer or $
:expected_stderr_regex: test_illegal_cg_matches_zero\.sv:28:
*/
// The matches clause gives the minimum number of satisfying value
// tuples needed to select a bin tuple, as a positive integer, or $
// for all of them. Zero is not allowed.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

module test_illegal_cg_matches_zero;
  covergroup cg(input int a, input int b);
    pa: coverpoint a;
    pb: coverpoint b;
    cr: cross pa, pb {
      bins s = cr with (1) matches 0;   // illegal: not positive
    }
  endgroup
endmodule

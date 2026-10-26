/*
:name: test_illegal_cg_bins_other_cross
:description: a cross bin select expression names another cross (IEEE 1800-2023 Section 19.6.1.2)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.6.1.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the bins clause of cross x2 uses x1, a different cross of the same covergroup
:expected_stderr_regex: test_illegal_cg_bins_other_cross\.sv:32:
*/
// In a select expression, only the identifier of the enclosing cross may
// be used; other cross identifiers are disallowed. The bin of x2 here
// names x1.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

module test_illegal_cg_bins_other_cross;
  covergroup cg(input int a, input int b, input int c);
    pa: coverpoint a;
    pb: coverpoint b;
    pc: coverpoint c;
    x1: cross pa, pb {
      bins p = binsof(pa);
    }
    x2: cross pa, pc {
      bins q = x1 with (1);   // illegal: x1 is another cross
    }
  endgroup
endmodule

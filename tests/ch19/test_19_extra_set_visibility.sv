/*
:name: test_19_extra_set_visibility
:description: A coverpoint identifier is not visible inside the set expression of a bin, so naming the containing coverpoint as a range bound is an error (IEEE 1800-2023 Section 19.5.1.2)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5.1.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the set expression of bin v uses cp, the name of its own coverpoint, which is not visible there
:expected_stderr_regex: test_19_extra_set_visibility\.sv:28:
*/
// IEEE 1800-2023 §19.5.1.2: a set expression is evaluated when the
// covergroup is constructed, and the coverpoint and bin identifiers of the
// covergroup are not visible in it. So a set expression can use constants
// and names from the enclosing scope, but not cp itself. Verilator 5.052
// reports cp as an undefined variable on that line, which is the name
// resolution result the clause requires. The construction-time evaluation
// of a nonconstant set expression is not tested: Verilator 5.052 requires
// the bounds of a range in a bin to be constant expressions.

module test_19_extra_set_visibility;
  bit [1:0] a;

  covergroup cg;
    cp: coverpoint a {
      bins v = {[cp:1]};   // illegal: cp is not visible here
    }
  endgroup
endmodule

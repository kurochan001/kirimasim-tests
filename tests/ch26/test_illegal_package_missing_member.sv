/*
:name: test_illegal_package_missing_member
:description: A reference to a name that the package does not declare is an error (IEEE 1800-2023 Section 26.3)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: p::missing names nothing in the package p
:expected_stderr_regex: test_illegal_package_missing_member\.sv:23:
*/
// IEEE 1800-2023 §26.3: a reference to an identifier that is not a call of a
// subroutine is illegal when no matching declaration can be found; p has no
// member named missing.

package p;
  int present = 1;
endpackage

module test_illegal_package_missing_member;
  initial $display("%0d", p::missing);   // illegal: p has no missing
endmodule

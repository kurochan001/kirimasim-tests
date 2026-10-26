/*
:name: test_illegal_std_package_declaration
:description: a user unit declares the built-in package std (IEEE 1800-2023 Section 26.7)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the package std is the built-in package, to which users cannot add declarations
:expected_stderr_regex: test_illegal_std_package_declaration\.sv:(18|19):
*/
// The built-in package std holds system types, variables and
// subroutines, and users cannot insert additional declarations into it.
// This compilation unit tries to declare the package std itself.

package std;
  int extra;   // illegal: adds a declaration to the built-in package
endpackage
module t;
endmodule

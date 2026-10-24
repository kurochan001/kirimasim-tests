/*
:name: test_illegal_package_net_declaration_assignment
:description: Since a package cannot contain processes outside checkers, a net declaration assignment, which is an implicit continuous assignment, is illegal in a package, while a net declaration without one and a variable with an initializer are legal (IEEE 1800-2023 Section 26.2)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the net declaration of ready in the package pna_pkg has an assignment
:expected_stderr_regex: test_illegal_package_net_declaration_assignment\.sv:26:
*/
// IEEE 1800-2023 §26.2: packages may contain processes inside checkers only,
// and therefore net declarations with implicit continuous assignments are not
// allowed in them. pna_pkg declares the net idle without an assignment and the
// variable level with an initializer, both legal, and the net ready with a
// net declaration assignment.
// Icarus Verilog 13.0 does not support nets in packages (syntax error on the
// legal idle), which does not count; the 5.052 release of Verilator accepts
// the design.

package pna_pkg;
  wire idle;
  logic level = 1'b1;
  wire ready = 1'b1;   // illegal: an implicit continuous assignment in a package
endpackage

module test_illegal_package_net_declaration_assignment;
  initial #1 $display("%b", pna_pkg::level);
endmodule

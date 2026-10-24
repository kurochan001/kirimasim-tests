/*
:name: test_illegal_package_import_hierarchical_access
:description: a name that a module imports from a package cannot be reached by a hierarchical name through that module (IEEE 1800-2023 Section 26.3)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the top module reads u.shared, but shared is only imported into module ih_user, not declared there
:expected_stderr_regex: test_illegal_package_import_hierarchical_access\.sv:33:
*/
// IEEE 1800-2023 §26.3: an import makes a package declaration visible in the
// importing scope without copying it into that scope, so the declaration
// cannot be referenced through the importing scope from outside, by a
// hierarchical name. Module ih_user imports ih_pkg::shared and declares
// own; the top module reads u.own, which is legal, and u.shared.

package ih_pkg;
  int shared = 4;
endpackage

module ih_user;
  import ih_pkg::shared;
  int own = 5;
  initial #1 shared = own;
endmodule

module test_illegal_package_import_hierarchical_access;
  ih_user u ();
  initial #2 $display("%0d", u.own);
  initial #3 $display("%0d", u.shared);   // illegal
endmodule

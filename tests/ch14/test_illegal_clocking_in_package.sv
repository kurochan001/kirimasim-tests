/*
:name: test_illegal_clocking_in_package
:description: A clocking block cannot be declared in a package (IEEE 1800-2023 Section 14.7)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.7 14.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a clocking block is declared inside a package
:expected_stderr_regex: test_illegal_clocking_in_package\.sv:19:
*/
// IEEE 1800-2023 §14.7: a clocking block can be declared only in a module,
// interface, checker or program, not in a package. The package below gives the
// illegal declaration at line 19.

package test_illegal_clocking_in_package_pkg;
  clocking cb @(posedge clk); endclocking
endpackage

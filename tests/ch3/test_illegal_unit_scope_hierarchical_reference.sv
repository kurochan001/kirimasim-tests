/*
:name: test_illegal_unit_scope_hierarchical_reference
:description: A hierarchical name that tries to reach a compilation-unit variable through a top-level module is rejected (IEEE 1800-2023 Section 3.12.1)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.12.1 23.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: unit_count is declared in the compilation-unit scope, whose identifiers are not reachable through hierarchical references
:expected_stderr_regex: test_illegal_unit_scope_hierarchical_reference\.sv:31:
*/
// IEEE 1800-2023 §3.12.1: the identifiers of the compilation-unit scope are
// visible by their simple names (or with $unit::) inside the compilation
// unit, but they are not accessible through hierarchical references. The
// hierarchical name on the marked line starts at the top-level instance of
// this module, which does not declare unit_count, so the name is an error.
// The simple name and the $unit:: name of the same variable on the lines
// before it, and the hierarchical name of the module's own variable, are
// legal.

int unit_count = 4;

module test_illegal_unit_scope_hierarchical_reference;
  int own = 1;

  initial begin
    $display("%0d %0d", unit_count, $unit::unit_count);
    $display("%0d", test_illegal_unit_scope_hierarchical_reference.own);
    $display("%0d", test_illegal_unit_scope_hierarchical_reference.unit_count);   // illegal
  end
endmodule

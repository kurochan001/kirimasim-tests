/*
:name: test_illegal_clocking_at_unit_scope
:description: A clocking block cannot be declared at the compilation-unit scope (IEEE 1800-2023 Section 14.7)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.7 14.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a clocking block is declared outside every module, interface, checker and program
:expected_stderr_regex: test_illegal_clocking_at_unit_scope\.sv:18:
*/
// IEEE 1800-2023 §14.7: a clocking block can be declared only inside a module,
// interface, checker or program, and not outside all declarations in a
// compilation unit. The declaration below gives the illegal block at line 18.

clocking cb @(posedge clk); endclocking

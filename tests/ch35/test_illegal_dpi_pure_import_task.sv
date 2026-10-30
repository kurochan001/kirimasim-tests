/*
:name: test_illegal_dpi_pure_import_task
:description: An imported task can never be declared pure, only context (IEEE 1800-2023 Section 35.5.1.3)
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.5.1.3 35.5.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an import declaration of a task has the property pure
:expected_stderr_regex: test_illegal_dpi_pure_import_task\.sv:23:
*/
// IEEE 1800-2023 §35.5.1.3: pure is for functions whose result depends only
// on their inputs, and an imported task can never be declared pure. The
// syntax of 35.5.4 allows only context as the property of an imported task
// (dpi_task_import_property). c_step is a task declared pure, which is an
// error at its declaration.
// Icarus Verilog 13.0 does not support DPI, so the syntax error it reports on
// that line does not count. Verilator 5.052 accepts the design.

module test_illegal_dpi_pure_import_task;
  import "DPI-C" pure task c_step(input int v);   // illegal: a pure imported task

  initial c_step(1);
endmodule

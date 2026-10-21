/*
:name: test_illegal_dpi_import_task_in_expression
:description: An imported task returns no value and can only be called as a statement, so its call cannot be the right-hand side of an assignment (IEEE 1800-2023 Section 35.2.1)
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.2.1 35.5.4 13.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the call of an imported task is used as an operand of an assignment
:expected_stderr_regex: test_illegal_dpi_import_task_in_expression\.sv:30:
*/
// IEEE 1800-2023 §35.2.1: an imported task has the semantics of a native
// task: it returns no value (void), so it can only be used in statement
// context; 13.3 makes a task enable a statement. The first call of c_work is
// such a statement; the second one is the right-hand side of an assignment,
// which is an error. The C code for the foreign side of the import is not
// needed, since the design is rejected first.
// Icarus Verilog 13.0 does not support DPI and reports a syntax error at the
// import declaration, which is not the line of the error.

module test_illegal_dpi_import_task_in_expression;
  import "DPI-C" task c_work(input int v);

  int r;

  initial begin
    c_work(1);
    r = c_work(2);   // illegal: an imported task used as a value
  end
endmodule

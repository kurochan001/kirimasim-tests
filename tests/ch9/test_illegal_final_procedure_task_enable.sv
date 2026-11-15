/*
:name: test_illegal_final_procedure_task_enable
:description: A final procedure can only contain the statements allowed in a function, so it cannot enable a task, even one without time-controlling statements (IEEE 1800-2023 Section 9.2.3)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.2.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second final procedure enables the task report_task
:expected_stderr_regex: test_illegal_final_procedure_task_enable\.sv:40:
*/
// IEEE 1800-2023 §9.2.3: the only statements allowed in a final procedure
// are those permitted in a function declaration. §13.4 b): a function shall
// not enable tasks, whether or not those tasks contain time-controlling
// statements. report_func and report_task have the same body, a $display
// without any timing control. The first final procedure calls the function
// report_func, which is legal; the second one enables the task report_task,
// and that line is the error. With report_func called in its place the
// design is legal and prints v=1 and v=2, in either order (the order of
// final procedures is not fixed).
// Icarus Verilog 13.0 reports on the line of the error that a final
// procedure cannot enable a task. The 5.054 release of Verilator accepts
// the design.

module test_illegal_final_procedure_task_enable;
  function automatic void report_func(int v);
    $display("v=%0d", v);
  endfunction

  task automatic report_task(int v);
    $display("v=%0d", v);
  endtask

  initial #5 $finish;

  final report_func(1);

  final report_task(2);   // illegal: a task enable in a final procedure
endmodule

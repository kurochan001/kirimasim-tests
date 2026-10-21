/*
:name: test_illegal_module_calls_program_task
:description: A design module cannot call a subroutine declared in a program (IEEE 1800-2023 Section 24.5)
:tags: ch24
:type: elaboration
:lrm: 1800-2023 24.5 24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a module calls a task declared in a program
:expected_stderr_regex: test_illegal_module_calls_program_task\.sv:28:
*/
// IEEE 1800-2023 §24.5: calling program subroutines from within design modules
// is illegal and shall result in an error, while a program can call the
// subroutines of a module.
// Icarus Verilog 13.0 and Verilator 5.052 accept the design
// (docs/simulator-differences.md).

program test_illegal_module_calls_program_task_p;
  task automatic report(int v);
    $display("v=%0d", v);
  endtask
endprogram

module test_illegal_module_calls_program_task;
  test_illegal_module_calls_program_task_p p();
  initial p.report(5);   // illegal: a module calls a program task
endmodule

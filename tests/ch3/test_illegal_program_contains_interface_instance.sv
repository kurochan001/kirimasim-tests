/*
:name: test_illegal_program_contains_interface_instance
:description: A program that contains an interface instance is rejected (IEEE 1800-2023 Section 3.4)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.4 24.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the program contains an interface instance, which a program cannot contain
:expected_stderr_regex: test_illegal_program_contains_interface_instance\.sv:28:
*/
// IEEE 1800-2023 §3.4: a program cannot contain interface instances (nor
// always procedures or primitive, module or program instances); §24.3 states
// the same. The interface is legal and the top-level module instantiates it,
// which is allowed; only the interface instance inside the program, on the
// marked line, breaks the rule.

interface test_illegal_program_contains_interface_instance_if;
  int data = 3;
endinterface

program test_illegal_program_contains_interface_instance_p;
  int copy;

  initial #1 $display("copy=%0d", copy);
  test_illegal_program_contains_interface_instance_if own_if();   // illegal
endprogram

module test_illegal_program_contains_interface_instance;
  test_illegal_program_contains_interface_instance_if bus();
  test_illegal_program_contains_interface_instance_p p();
endmodule

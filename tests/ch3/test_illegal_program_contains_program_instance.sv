/*
:name: test_illegal_program_contains_program_instance
:description: A program that contains an instance of another program is rejected (IEEE 1800-2023 Section 3.4)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.4 24.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the program contains an instance of another program, which a program cannot contain
:expected_stderr_regex: test_illegal_program_contains_program_instance\.sv:26:
*/
// IEEE 1800-2023 §3.4: a program cannot contain other program instances (nor
// always procedures or primitive, module or interface instances); §24.3
// states the same. The child program is legal and the module instantiates
// it, which is allowed; only its instance inside the outer program, on the
// marked line, breaks the rule.

program test_illegal_program_contains_program_instance_child;
  initial $display("child");
endprogram

program test_illegal_program_contains_program_instance_outer;
  initial $display("outer");
  test_illegal_program_contains_program_instance_child nested();   // illegal
endprogram

module test_illegal_program_contains_program_instance;
  test_illegal_program_contains_program_instance_child c();
  test_illegal_program_contains_program_instance_outer o();
endmodule

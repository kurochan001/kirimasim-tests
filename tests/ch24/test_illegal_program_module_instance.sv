/*
:name: test_illegal_program_module_instance
:description: A program cannot contain an instance of a module (IEEE 1800-2023 Section 24.3)
:tags: ch24
:type: elaboration
:lrm: 1800-2023 24.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the program instantiates a module
:expected_stderr_regex: test_illegal_program_module_instance\.sv:22:
*/
// IEEE 1800-2023 §24.3: a program is a leaf of the hierarchy; it shall not
// contain declarations or instances of modules, interfaces or other programs.

module test_illegal_program_module_instance_leaf;
  initial $display("leaf");
endmodule

program test_illegal_program_module_instance_p;
  test_illegal_program_module_instance_leaf u();   // illegal: module instance in a program
  initial $display("program");
endprogram

module test_illegal_program_module_instance;
  test_illegal_program_module_instance_p p();
endmodule

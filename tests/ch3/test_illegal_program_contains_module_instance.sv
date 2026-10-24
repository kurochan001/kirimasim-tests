/*
:name: test_illegal_program_contains_module_instance
:description: A program that contains a module instance is rejected (IEEE 1800-2023 Section 3.4)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.4 24.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the program contains a module instance, which a program cannot contain
:expected_stderr_regex: test_illegal_program_contains_module_instance\.sv:28:
*/
// IEEE 1800-2023 §3.4: a program cannot contain module instances (nor
// always procedures or primitive, interface or program instances); §24.3
// states the same. The leaf module is legal and the top-level module also
// instantiates it, which is allowed; only its instance inside the program, on
// the marked line, breaks the rule.

module test_illegal_program_contains_module_instance_leaf(output int v);
  assign v = 7;
endmodule

program test_illegal_program_contains_module_instance_p;
  int seen;

  initial #1 $display("seen=%0d", seen);
  test_illegal_program_contains_module_instance_leaf u_in_prog(.v(seen));   // illegal
endprogram

module test_illegal_program_contains_module_instance;
  int v_top;
  test_illegal_program_contains_module_instance_leaf u_in_mod(.v(v_top));
  test_illegal_program_contains_module_instance_p p();
endmodule

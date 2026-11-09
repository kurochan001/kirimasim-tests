/*
:name: test_illegal_program_nested_module_declaration
:description: A program cannot contain a module declaration (IEEE 1800-2023 Section 24.3)
:tags: ch24
:type: elaboration
:lrm: 1800-2023 24.3 A.1.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the program declares the module pnm_inner inside its body
:expected_stderr_regex: test_illegal_program_nested_module_declaration\.sv:36:
*/
// IEEE 1800-2023 §24.3: a program may contain data declarations, class
// definitions, subroutines, object instances and initial or final
// procedures, but it shall not contain declarations or instances of modules,
// interfaces or other programs. A.1.7 has no module declaration among the
// program items. The module that instantiates the program declares a nested
// module of its own, which is legal (23.4); the program has a variable and an
// initial procedure, and only the module declaration on the marked line
// breaks the rule.
// Icarus Verilog 13.0 rejects the marked line because declarations are not
// allowed in program blocks. Verilator 5.052 does not support module
// declarations within modules and reports a syntax error at the marked line,
// which is not counted.

module test_illegal_program_nested_module_declaration;
  module pnm_ok;
    initial $display("nested module in a module");
  endmodule
  pnm_prog p ();
endmodule

program pnm_prog;
  int n = 1;
  module pnm_inner;   // illegal: a module declaration in a program
    initial $display("inner");
  endmodule
  initial $display("n=%0d", n);
endprogram

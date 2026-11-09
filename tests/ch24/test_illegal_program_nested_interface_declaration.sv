/*
:name: test_illegal_program_nested_interface_declaration
:description: A program cannot contain an interface declaration (IEEE 1800-2023 Section 24.3)
:tags: ch24
:type: elaboration
:lrm: 1800-2023 24.3 A.1.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the program declares the interface pni_inner inside its body
:expected_stderr_regex: test_illegal_program_nested_interface_declaration\.sv:35:
*/
// IEEE 1800-2023 §24.3: a program shall not contain declarations or
// instances of modules, interfaces or other programs. A.1.7 has no interface
// declaration among the program items. The module that instantiates the
// program declares and instantiates an interface of its own, which is legal
// (25.3); the program has a variable and an initial procedure, and only the
// interface declaration on the marked line breaks the rule.
// Icarus Verilog 13.0 rejects the marked line because declarations are not
// allowed in program blocks. Verilator 5.052 does not support interface
// declarations within modules and reports a syntax error at the marked line,
// which is not counted.

module test_illegal_program_nested_interface_declaration;
  interface pni_ok;
    int k = 2;
  endinterface
  pni_ok u_ok ();
  pni_prog p ();
endmodule

program pni_prog;
  int n = 1;
  interface pni_inner;   // illegal: an interface declaration in a program
    int k;
  endinterface
  initial $display("n=%0d", n);
endprogram

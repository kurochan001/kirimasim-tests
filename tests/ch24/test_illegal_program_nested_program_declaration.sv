/*
:name: test_illegal_program_nested_program_declaration
:description: A program cannot contain the declaration of another program (IEEE 1800-2023 Section 24.3)
:tags: ch24
:type: elaboration
:lrm: 1800-2023 24.3 A.1.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the program pnp_outer declares the program pnp_inner inside its body
:expected_stderr_regex: test_illegal_program_nested_program_declaration\.sv:35:
*/
// IEEE 1800-2023 §24.3: a program shall not contain declarations or
// instances of modules, interfaces or other programs, while programs can be
// nested in modules and interfaces. A.1.7 has no program declaration among
// the program items. The top module declares the nested program pnp_ok,
// which is legal and instantiated implicitly once; pnp_outer has a variable
// and an initial procedure, and only the program declaration on the marked
// line breaks the rule.
// Icarus Verilog 13.0 rejects the marked line because declarations are not
// allowed in program blocks. Verilator 5.052 does not support program
// declarations within modules and reports a syntax error at the marked line,
// which is not counted.

module test_illegal_program_nested_program_declaration;
  program pnp_ok;
    initial $display("nested program in a module");
  endprogram
  pnp_outer p ();
endmodule

program pnp_outer;
  int n = 1;
  program pnp_inner;   // illegal: a program declaration in a program
    initial $display("inner");
  endprogram
  initial $display("n=%0d", n);
endprogram

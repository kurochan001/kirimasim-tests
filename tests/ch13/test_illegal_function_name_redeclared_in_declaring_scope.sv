/*
:name: test_illegal_function_name_redeclared_in_declaring_scope
:description: no other object can be declared with the name of a function in the scope that declares the function (IEEE 1800-2023 Section 13.4.1)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module declares the function doubled and then a variable also named doubled in the same scope
:expected_stderr_regex: test_illegal_function_name_redeclared_in_declaring_scope\.sv:(25|28):
*/
// IEEE 1800-2023 §13.4.1: it is illegal to declare another object with the
// same name as a function in the scope where the function is declared. The
// module declares the function doubled and, after it, the int variable
// doubled. Without the variable the design is legal and prints the result
// of the call doubled(3), 6.
// A tool can report the error at the variable or at the function whose name
// it takes. Icarus Verilog 13.0 reports at the variable that the name is
// already declared in the scope. The 5.054 release of Verilator reports the
// variable as an unsupported construct, which does not count.

module test_illegal_function_name_redeclared_in_declaring_scope;
  function int doubled(input int a);
    return 2 * a;
  endfunction
  int doubled;   // illegal: another object with the name of the function
  initial $display("%0d", doubled(3));
endmodule

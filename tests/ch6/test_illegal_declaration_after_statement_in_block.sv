/*
:name: test_illegal_declaration_after_statement_in_block
:description: The variable declarations of a procedural block come before its statements; a declaration after a statement is an error (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.21 9.3.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable b is declared after the statement a = 1 in the same begin-end block
:expected_stderr_regex: test_illegal_declaration_after_statement_in_block\.sv:22:
*/
// IEEE 1800-2023 §6.21: variable declarations shall precede any statements
// within a procedural block (a begin-end block, §9.3.1, declares its items
// before its statements). The declaration of b follows the statement a = 1.

module test_illegal_declaration_after_statement_in_block;
  initial begin
    int a;
    a = 1;
    int b;    // illegal: declaration after a statement
    b = a;
  end
endmodule

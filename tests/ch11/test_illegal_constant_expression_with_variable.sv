/*
:name: test_illegal_constant_expression_with_variable
:description: the operands of a constant expression are constant numbers, strings, parameters, selects of parameters and constant function and system function calls, not variables (IEEE 1800-2023 Section 11.2.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.2.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the value of the local parameter BAD, which has to be a constant expression, uses the variable v
:expected_stderr_regex: test_illegal_constant_expression_with_variable\.sv:33:
*/
// IEEE 1800-2023 §11.2.1: the operands of a constant expression are constant
// numbers, strings, parameters, constant bit-selects and part-selects of
// parameters, non-void constant function calls, constant system function
// calls and constant built-in method calls. The local parameters before BAD
// use each kind except built-in methods, which is legal; BAD uses the
// variable v.

module test_illegal_constant_expression_with_variable;
  localparam logic [7:0] P = 8'hb4;
  int v = 3;

  function automatic int twice(int x);
    return 2 * x;
  endfunction

  localparam int A = 5 + P;
  localparam int B = P[3:0] + P[7];
  localparam int C = twice(4) + $clog2(16);
  localparam logic [15:0] D = "hi";
  localparam int BAD = v + 1;   // illegal: a variable in a constant expression

  initial $display("%0d %0d %0d %h", A, B, C, D);
endmodule

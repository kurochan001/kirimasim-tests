/*
:name: test_illegal_void_function_in_expression
:description: A void function cannot be called as part of an expression (IEEE 1800-2023 Section 13.4.1)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the call of a void function is the operand of an assignment
:expected_stderr_regex: test_illegal_void_function_in_expression\.sv:25:
*/
// IEEE 1800-2023 §13.4.1: function calls can be expressions unless the function
// is void; the call of a void function is a statement.

module test_illegal_void_function_in_expression;
  int count;
  function void bump();
    count++;
  endfunction
  int r;
  initial begin
    count = 0;
    r = bump();   // illegal: a void function in an expression
    $display("r=%0d", r);
  end
endmodule

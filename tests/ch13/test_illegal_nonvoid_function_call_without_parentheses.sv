/*
:name: test_illegal_nonvoid_function_call_without_parentheses
:description: the parentheses of a call can be left out only for a task, a void function or a class method (IEEE 1800-2023 Section 13.5)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the nonvoid function get_k, which is not a class method, is called without parentheses
:expected_stderr_regex: test_illegal_nonvoid_function_call_without_parentheses\.sv:35:
*/
// IEEE 1800-2023 §13.5 (footnote 42 of Syntax 13-3): it shall be illegal to
// leave out the parentheses of a call unless the subroutine is a task, a void
// function or a class method. The void function bump and the task show are
// called without parentheses, which is legal, and the nonvoid function get_k
// is called with them; the last statement calls get_k without them.

module test_illegal_nonvoid_function_call_without_parentheses;
  int k = 5, x, y;
  function int get_k();
    return k;
  endfunction
  function void bump();
    k = k + 1;
  endfunction
  task show();
    $display("%0d", k);
  endtask
  initial begin
    bump;
    show;
    x = get_k();
    y = get_k;   // illegal
  end
endmodule

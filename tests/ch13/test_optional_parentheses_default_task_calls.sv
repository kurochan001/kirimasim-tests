/*
:name: test_optional_parentheses_default_task_calls
:description: A task with all arguments defaulted may be called with or without empty parentheses (IEEE 1800-2023 Section 13.5.5)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_optional_parentheses_default_task_calls.expected
*/
// IEEE 1800-2023 13.5.5: Both forms must apply the same declared default and
// execute the task, rather than referencing an unevaluated method.

module test_optional_parentheses_default_task_calls;
  int count;
  task automatic add_default(int amount = 3); count += amount; endtask
  function automatic void bump(); count++; endfunction
  initial begin
    add_default; add_default(); bump; bump();
    $display("count=%0d", count);
  end
endmodule

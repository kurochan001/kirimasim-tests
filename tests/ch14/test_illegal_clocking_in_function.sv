/*
:name: test_illegal_clocking_in_function
:description: A clocking block cannot be declared in a function (IEEE 1800-2023 Section 14.7)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.7 14.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a clocking block is declared inside a function
:expected_stderr_regex: test_illegal_clocking_in_function\.sv:24:
*/
// IEEE 1800-2023 §14.7: a clocking block can be declared only inside a
// module, interface, checker or program, not inside a function or task or
// package, and not outside all declarations in a compilation unit. The
// function below gives the illegal declaration at line 24. The module
// declares clk, so the clocking event names a signal and the place of the
// declaration is the only error.

module test_illegal_clocking_in_function;
  logic clk;
  function automatic void f();
    clocking cb @(posedge clk); endclocking
  endfunction
endmodule

/*
:name: test_illegal_disable_function
:description: a function cannot be disabled, while a named block inside a function and a task disabling itself can (IEEE 1800-2023 Section 9.6.2)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.6.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function clip names itself in a disable statement
:expected_stderr_regex: test_illegal_disable_function\.sv:32:
*/
// IEEE 1800-2023 §9.6.2: a task or a named block may disable itself, and a
// named block inside a function may be disabled, but a function cannot be
// disabled. The task stop_t and the block run_b disable themselves, and clip
// disables its named block lim_b; then clip names itself in a disable.

module test_illegal_disable_function;
  int n;

  task stop_t();
    n = n + 1;
    disable stop_t;
  endtask

  function automatic int clip(int x);
    begin : lim_b
      if (x > 9) disable lim_b;
      x = x + 1;
    end
    if (x > 20) disable clip;   // illegal: a function cannot be disabled
    return x;
  endfunction

  initial begin
    begin : run_b
      stop_t();
      disable run_b;
    end
    $display("%0d %0d", n, clip(3));
  end
endmodule

/*
:name: test_illegal_function_delay
:description: A function cannot contain a delay control (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function f has a delay control
:expected_stderr_regex: test_illegal_function_delay\.sv:19:
*/
// IEEE 1800-2023 §13.4: a function executes in no simulation time, so it cannot
// contain time-controlling statements such as #.

module test_illegal_function_delay;
  function int f(int x);
    #1 return x + 1;   // illegal: a delay in a function
  endfunction
  initial $display("%0d", f(1));
endmodule

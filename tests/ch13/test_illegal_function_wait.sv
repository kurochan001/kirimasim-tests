/*
:name: test_illegal_function_wait
:description: A function cannot contain a wait statement (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4 9.4.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function contains a wait statement
:expected_stderr_regex: test_illegal_function_wait\.sv:21:
*/
// IEEE 1800-2023 §13.4: a function shall not contain time-controlling
// statements, among them wait (§9.4.3), so that it returns without suspending
// the process that called it.

module test_illegal_function_wait;
  logic ready = 1;
  function int when_ready(int v);
    wait (ready);   // illegal: wait in a function
    return v;
  endfunction
  initial $display("v=%0d", when_ready(3));
endmodule

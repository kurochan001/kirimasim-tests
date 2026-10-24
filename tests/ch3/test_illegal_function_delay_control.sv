/*
:name: test_illegal_function_delay_control
:description: A function whose body contains a delay control, which would block simulation time, is rejected (IEEE 1800-2023 Section 3.8)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.8 13.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function contains a delay control, so its execution would block simulation time
:expected_stderr_regex: test_illegal_function_delay_control\.sv:25:
*/
// IEEE 1800-2023 §3.8: a function executes without blocking simulation time
// (only processes it forks off may block). §13.4 makes this concrete: a
// function shall not contain a time-controlling statement such as #, @ or
// wait. The function below is otherwise legal; the delay control on the
// marked line is the only error. The tests with an event control and a wait
// statement check the other forms.

module test_illegal_function_delay_control;
  int last;

  function int store_later(int v);
    #1 last = v;   // illegal: a delay control in a function
    return v + 1;
  endfunction

  initial $display("r=%0d", store_later(4));
endmodule

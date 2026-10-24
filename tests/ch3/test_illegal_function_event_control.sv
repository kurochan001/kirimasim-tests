/*
:name: test_illegal_function_event_control
:description: A function whose body contains an event control, which would block simulation time, is rejected (IEEE 1800-2023 Section 3.8)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.8 13.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function contains an event control, so its execution would block simulation time
:expected_stderr_regex: test_illegal_function_event_control\.sv:26:
*/
// IEEE 1800-2023 §3.8: a function executes without blocking simulation time
// (only processes it forks off may block). §13.4 makes this concrete: a
// function shall not contain a time-controlling statement such as #, @ or
// wait. The function below is otherwise legal; the event control on the
// marked line is the only error. The tests with a delay control and a wait
// statement check the other forms.

module test_illegal_function_event_control;
  event go;
  int last;

  function int store_on_event(int v);
    @(go) last = v;   // illegal: an event control in a function
    return v + 1;
  endfunction

  initial $display("r=%0d", store_on_event(4));
endmodule

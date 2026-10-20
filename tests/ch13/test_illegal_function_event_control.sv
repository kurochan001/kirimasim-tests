/*
:name: test_illegal_function_event_control
:description: A function cannot contain an event control (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function f waits for an event
:expected_stderr_regex: test_illegal_function_event_control\.sv:20:
*/
// IEEE 1800-2023 §13.4: @ is one of the time-controlling statements that a
// function cannot contain.

module test_illegal_function_event_control;
  event e;
  function int f(int x);
    @(e);              // illegal: an event control in a function
    return x;
  endfunction
  initial $display("%0d", f(1));
endmodule

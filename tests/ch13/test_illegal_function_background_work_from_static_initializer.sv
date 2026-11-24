/*
:name: test_illegal_function_background_work_from_static_initializer
:description: A static initializer cannot call a function that schedules work after returning
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4.4 6.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initializer calls a function that spawns a delayed child before any initial or always thread
:expected_stderr_regex: test_illegal_function_background_work_from_static_initializer\.sv:24:(?:\d+:)?[^\n]*(?i:(?:initializ[^\n]*(?:fork|spawn|side effect|schedule|nonblocking)|(?:fork|spawn|side effect|schedule|nonblocking)[^\n]*(?:initializ|initial value[^\n]*static|thread|context)))
*/
`timescale 1ns/1ns
module test_illegal_function_background_work_from_static_initializer;
  int completed;
  function automatic int launch();
    fork
      #3 completed = 21;
    join_none
    return 17;
  endfunction

  int initial_value = launch(); // illegal
  initial #5 $display("initial=%0d completed=%0d", initial_value, completed);
endmodule

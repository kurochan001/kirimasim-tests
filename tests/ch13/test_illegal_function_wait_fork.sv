/*
:name: test_illegal_function_wait_fork
:description: a function cannot contain a wait fork statement, even after it starts processes with fork-join_none (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function start_and_wait contains wait fork
:expected_stderr_regex: test_illegal_function_wait_fork\.sv:28:
*/
// IEEE 1800-2023 13.4 a): a function shall not contain time-controlling
// statements, and wait fork is one of them. 13.4.4 allows a function to start
// processes with fork-join_none, and start_and_wait does so; the wait fork
// after it, which would block until the started process ends, is illegal.
// Without that line the design prints done=0: the started process runs only
// when the initial procedure blocks (9.3.2), and it prints done=1 after #3.

module test_illegal_function_wait_fork;
  int done = 0;

  function void start_and_wait();
    fork
      done = 1;
    join_none
    wait fork;   // illegal: wait fork in a function
  endfunction

  initial begin
    start_and_wait();
    $display("done=%0d", done);
    #3 $display("done=%0d", done);
  end
endmodule

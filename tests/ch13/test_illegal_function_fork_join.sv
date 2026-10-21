/*
:name: test_illegal_function_fork_join
:description: A function cannot contain a fork-join block (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4 13.4.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function f contains fork-join
:expected_stderr_regex: test_illegal_function_fork_join\.sv:(22|25):
*/
// IEEE 1800-2023 §13.4: fork-join waits for the processes it starts, so a
// function cannot contain it (only fork-join_none is allowed, 13.4.4). The
// error is the statement; a tool can rightly report it at the fork or at the
// join, as for fork-join_any (ch13/test_illegal_function_fork_join_any).

module test_illegal_function_fork_join;
  int n;
  function void f();
    fork               // illegal: fork-join in a function
      n = 1;
      n = 2;
    join               // where the block waits
  endfunction
  initial f();
endmodule

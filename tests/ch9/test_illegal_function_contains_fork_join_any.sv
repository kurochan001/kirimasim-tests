/*
:name: test_illegal_function_contains_fork_join_any
:description: A function cannot contain a fork-join_any block (IEEE 1800-2023 Sections 9.3.2 and 13.4)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.3.2 13.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function body contains a fork-join_any block
:expected_stderr_regex: test_illegal_function_contains_fork_join_any\.sv:24:
*/
// IEEE 1800-2023 §9.3.2: parallel blocks have restricted use inside
// functions (13.4): a function shall not contain time-controlling
// statements, among them fork-join and fork-join_any; only fork-join_none
// is allowed (13.4.4). The function below has a fork-join_any.
// Icarus Verilog 13.0 accepts the design.

module test_illegal_function_contains_fork_join_any;
  int a, b;

  function automatic void either();
    fork   // illegal: fork-join_any inside a function
      a = 1;
      b = 2;
    join_any
  endfunction

  initial either();
endmodule

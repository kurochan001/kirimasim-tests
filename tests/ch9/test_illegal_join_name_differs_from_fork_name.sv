/*
:name: test_illegal_join_name_differs_from_fork_name
:description: a block name after join has to be the name of the block given after fork (IEEE 1800-2023 Section 9.3.4)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.3.4 9.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the parallel block named both_b ends with join : other_b
:expected_stderr_regex: test_illegal_join_name_differs_from_fork_name\.sv:32:
*/
// IEEE 1800-2023 §9.3.4: a block name may follow end, join, join_any or
// join_none after a colon; it shall be an error if it differs from the name
// of the block. The parallel block one_b ends with join and its own name, and
// two_b with join and no name, which is legal; both_b ends with join and
// another name.

module test_illegal_join_name_differs_from_fork_name;
  int a, b;

  initial begin
    fork : one_b
      a = 1;
    join : one_b
    fork : two_b
      b = 2;
    join
    fork : both_b
      a = a + b;
    join : other_b   // illegal: another name than both_b
    $display("%0d", a);
  end
endmodule

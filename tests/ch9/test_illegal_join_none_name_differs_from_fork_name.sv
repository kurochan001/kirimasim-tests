/*
:name: test_illegal_join_none_name_differs_from_fork_name
:description: a block name after join_none has to be the name of the block given after fork (IEEE 1800-2023 Section 9.3.4)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.3.4 9.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the parallel block named spawn_b ends with join_none : other_b
:expected_stderr_regex: test_illegal_join_none_name_differs_from_fork_name\.sv:31:
*/
// IEEE 1800-2023 §9.3.4: a block name may follow end, join, join_any or
// join_none after a colon; it shall be an error if it differs from the name
// of the block. The blocks seq_b and any_b end with their own names, which
// is legal; the parallel block spawn_b ends with join_none and another name.

module test_illegal_join_none_name_differs_from_fork_name;
  int a, b;

  initial begin
    begin : seq_b
      a = 1;
    end : seq_b
    fork : any_b
      b = 2;
    join_any : any_b
    fork : spawn_b
      #1 a = 3;
    join_none : other_b   // illegal: another name than spawn_b
    #2 $display("%0d %0d", a, b);
  end
endmodule

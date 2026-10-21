/*
:name: test_illegal_function_fork_join_any
:description: A function cannot contain fork-join_any (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4 13.4.4 9.3.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function contains a fork-join_any block
:expected_stderr_regex: test_illegal_function_fork_join_any\.sv:22:
*/
// IEEE 1800-2023 §13.4: a function shall not contain fork-join_any, which can
// block (§9.3.2); §13.4.4 allows only fork-join_none in a function.
// The design is accepted by Icarus Verilog 13.0
// (docs/simulator-differences.md).

module test_illegal_function_fork_join_any;
  int a, b;
  function void set_both(int v);
    fork   // illegal: fork-join_any in a function
      a = v;
      b = v;
    join_any
  endfunction
  initial begin
    set_both(4);
    $display("a=%0d b=%0d", a, b);
  end
endmodule

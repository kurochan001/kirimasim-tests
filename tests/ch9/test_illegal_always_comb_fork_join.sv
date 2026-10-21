/*
:name: test_illegal_always_comb_fork_join
:description: An always_comb procedure cannot contain fork-join (IEEE 1800-2023 Section 9.2.2.2.2)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.2.2.2.2 9.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the always_comb procedure has a fork-join statement
:expected_stderr_regex: test_illegal_always_comb_fork_join\.sv:24:
*/
// IEEE 1800-2023 §9.2.2.2.2: the statements of an always_comb procedure shall
// not include fork-join statements (§9.3.2), which block until their branches
// end.
// The design is accepted by Verilator 5.052 (docs/simulator-differences.md).

`timescale 1ns/1ns

module test_illegal_always_comb_fork_join;
  logic a = 0, b = 0, y, z;
  always_comb begin
    fork   // illegal: fork-join in always_comb
      y = a;
      z = b;
    join
  end
  initial #5 $display("y=%b z=%b", y, z);
endmodule

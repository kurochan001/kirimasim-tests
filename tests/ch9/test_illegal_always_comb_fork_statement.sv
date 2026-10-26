/*
:name: test_illegal_always_comb_fork_statement
:description: an always_comb procedure cannot contain a fork-join_none statement
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.2.2.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the always_comb procedure contains a fork-join_none statement
:expected_stderr_regex: test_illegal_always_comb_fork_statement\.sv:(?:23|25):
*/
// IEEE 1800-2023 9.2.2.2.2: the statements of an always_comb procedure shall
// not include fork-join statements. The fork below creates a parallel branch
// with join_none, so the always_comb is illegal. Icarus Verilog 13.0 rejects
// the fork; Verilator 5.052 accepts it.

module test_illegal_always_comb_fork_statement;
  logic a = 0, y;

  always_comb begin
    fork   // illegal: fork-join statement in always_comb
      y = a;
    join_none
  end

  initial #5 $display("y=%b", y);
endmodule

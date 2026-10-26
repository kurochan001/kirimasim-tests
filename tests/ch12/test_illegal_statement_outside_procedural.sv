/*
:name: test_illegal_statement_outside_procedural
:description: A procedural programming statement has to be contained in an initial, always, final, task or function, so a sequential block at module item scope is an error (IEEE 1800-2023 Section 12.2)
:tags: ch12
:type: elaboration
:lrm: 1800-2023 12.2 12.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a begin-end block with an assignment is written at module item scope, outside any procedural construct
:expected_stderr_regex: test_illegal_statement_outside_procedural\.sv:(25|26):
*/
// IEEE 1800-2023 §12.2: procedural programming statements shall be contained
// in a procedural block introduced by initial, always, always_comb,
// always_latch, always_ff or final, or in a task or function. The initial
// block below is legal. The begin-end block before it is a sequential block,
// which is a procedural statement, and module item scope is not one of the
// listed constructs, so the design is illegal. A tool can report the error at
// the begin keyword or at the assignment inside the block.

module test_illegal_statement_outside_procedural;
  int x = 0;

  begin : not_procedural       // illegal: statement at module item scope
    x = 1;
  end

  initial begin
    $display("x=%0d", x);
  end
endmodule

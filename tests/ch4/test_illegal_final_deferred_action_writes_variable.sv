/*
:name: test_illegal_final_deferred_action_writes_variable
:description: The action of a final deferred assertion runs in the Postponed region, where no net or variable may change, so it cannot call a subroutine that writes a module variable, while one that only prints is legal (IEEE 1800-2023 Section 4.4.2.9)
:tags: ch4
:type: elaboration
:lrm: 1800-2023 4.4.2.9 16.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the final deferred action of a1 calls count_up, which assigns the module variable hits while the action runs in the Postponed region, where writing a net or variable is illegal
:expected_stderr_regex: ^(?![^\n]*(?i:unsupported|not supported|not implemented|syntax error|invalid module))[^\n]*test_illegal_final_deferred_action_writes_variable\.sv:(?:37|42):(?:\d+:)?[^\n]*(?i:(?:writ|assign|modif|chang|variable|side.effect)[^\n]*(?:postponed|final)|(?:postponed|final)[^\n]*(?:writ|assign|modif|chang|variable|side.effect))
*/
// IEEE 1800-2023 §4.4.2.9: once the Postponed region of a time slot is
// reached, no value may change in that slot any more; writing any net or
// variable there is illegal. §16.4: the action of a final deferred assertion
// is a single subroutine call that is scheduled in the Postponed region, and
// the subroutine has to be one that may legally be called there.
// The action of a1 calls the void function count_up, whose only statement
// assigns the module variable hits, so the call is illegal. The action of a0
// calls report, which only prints and writes nothing, and is legal; nothing
// else in the design is illegal (a function may assign a module variable
// when it is called from ordinary procedural code). A tool may give the error
// at the assignment in count_up or at the call in a1.
// Icarus Verilog 13.0 does not support deferred assertions, which does not
// count as rejecting the design.

module test_illegal_final_deferred_action_writes_variable;
  logic a = 0;
  int hits = 0;

  function automatic void report();
    $display("a0 failed");
  endfunction

  function automatic void count_up();
    hits = hits + 1;
  endfunction

  always @(a) begin
    a0: assert final (a == 0) else report();
    a1: assert final (a == 0) else count_up();
  end

  initial begin
    #1 a = 1;
    #1 $display("hits=%0d", hits);
    $finish;
  end
endmodule

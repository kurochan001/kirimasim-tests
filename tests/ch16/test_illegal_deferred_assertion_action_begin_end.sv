/*
:name: test_illegal_deferred_assertion_action_begin_end
:description: the fail statement of a deferred assertion has to be a single subroutine call, not a begin-end block (IEEE 1800-2023 Section 16.4)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the fail action of the final deferred assertion d2 is a begin-end block around the call
:expected_stderr_regex: test_illegal_deferred_assertion_action_begin_end\.sv:34:
*/
// IEEE 1800-2023 §16.4: the pass and fail statements of a deferred assertion
// shall each be a single call of a task, task method, void function, void
// function method or system task, so no begin-end block may surround them.
// d0 calls the void function note as its pass statement and $error as its
// fail statement, and d1 calls the task show; d2 puts its call of $error
// in a begin-end block.
// Icarus Verilog 13.0 does not support deferred assertions, and Verilator
// 5.052 accepts the design.

module test_illegal_deferred_assertion_action_begin_end;
  logic a = 1;
  function void note(string s);
    $display("%s", s);
  endfunction
  task show(string s);
    $display("%s", s);
  endtask
  initial begin
    d0: assert #0 (a) note("d0 pass"); else $error("d0 fail");
    d1: assert final (a) show("d1 pass");
    d2: assert final (a) else begin $error("d2 fail"); end   // illegal
  end
endmodule

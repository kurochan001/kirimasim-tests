/*
:name: test_illegal_final_deferred_postponed_call
:description: a final deferred assertion calls a subroutine that is not legal in the Postponed region, because it writes a variable
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the final deferred action of a1 calls set_flag, which assigns flag, and no value may be written in the Postponed region
:expected_stderr_regex: test_illegal_final_deferred_postponed_call\.sv:29:
*/
// IEEE 1800-2023 §16.4, §16.4.1 and §4.4.2.9: the subroutine of a final
// deferred assertion runs in the Postponed region, so it shall be one that
// may legally be called there. No value may be written to a variable in the
// Postponed region. The action of a1 calls set_flag, which assigns flag, so
// the action is illegal. The design is otherwise legal.

module test_illegal_final_deferred_postponed_call;
  logic a = 0;
  int flag = 0;

  task automatic set_flag();
    flag = 1;
  endtask

  always @(a) begin
    a1: assert final (a == 0) else set_flag();   // illegal
  end

  initial begin
    a = 1;
    #1 $finish;
  end
endmodule

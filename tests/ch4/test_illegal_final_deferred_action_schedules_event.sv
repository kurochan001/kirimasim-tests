/*
:name: test_illegal_final_deferred_action_schedules_event
:description: The action of a final deferred assertion runs in the Postponed region, so it cannot call a subroutine that schedules an event in an earlier region of the time slot, such as a nonblocking event trigger, while one that only prints is legal (IEEE 1800-2023 Section 4.4.2.9)
:tags: ch4
:type: elaboration
:lrm: 1800-2023 4.4.2.9 16.4 15.5.1 13.4.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the final deferred action of a1 calls notify, whose ->> schedules the trigger of done in the NBA region of the current time slot while the action runs in the Postponed region
:expected_stderr_regex: ^(?![^\n]*(?i:unsupported|not supported|not implemented|syntax error|invalid module))[^\n]*test_illegal_final_deferred_action_schedules_event\.sv:(?:39|46):(?:\d+:)?[^\n]*(?i:(?:event|trigger|schedul)[^\n]*postponed|postponed[^\n]*(?:event|trigger|schedul))
*/
// IEEE 1800-2023 §4.4.2.9: once the Postponed region of a time slot is
// reached, it is illegal to schedule an event in any earlier region of that
// slot. §16.4: the action of a final deferred assertion is a single
// subroutine call scheduled in the Postponed region, and the subroutine has
// to be one that may legally be called there. §15.5.1: ->> without a delay
// creates an update event that triggers its event in the NBA region of the
// current time slot; §13.4.4 allows an event trigger in a function. The
// action of a1 calls the void function notify, whose ->> would schedule that
// event from the Postponed region, so the call is illegal. The action of a0
// calls report, which only prints, and is legal; nothing else in the design
// is illegal. A tool may give the error at the trigger in notify or at the
// call in a1.
// Icarus Verilog 13.0 does not support deferred assertions, which does not
// count, and the release 5.052 of Verilator accepts the design.

module test_illegal_final_deferred_action_schedules_event;
  logic a = 0;
  event done;
  int seen = 0;

  function automatic void report();
    $display("a0 failed");
  endfunction

  function automatic void notify();
    ->> done;
  endfunction

  always @(done) seen++;

  always @(a) begin
    a0: assert final (a == 0) else report();
    a1: assert final (a == 0) else notify();   // illegal
  end

  initial begin
    #1 a = 1;
    #1 $display("seen=%0d", seen);
    $finish;
  end
endmodule

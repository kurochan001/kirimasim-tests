/*
:name: test_class_event_assignment_binds_new_waiter_to_source
:description: An assigned class event binds subsequent waiters to the source event (IEEE 1800-2023 Section 15.5.5.1)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.5.5.1 9.3.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_event_assignment_binds_new_waiter_to_source.expected
:expected_exit: 0
*/
// A newly started waiter uses the event token copied from another object.
// Only the source object triggers the event.

module test_class_event_assignment_binds_new_waiter_to_source;
  class holder;
    event signal_event;
  endclass
  holder target, source;
  bit woke;
  initial begin
    target = new;
    source = new;
    target.signal_event = source.signal_event;
    fork
      begin @(target.signal_event); woke = 1; end
    join_none
    #1;
    ->source.signal_event;
    #1;
    $display("CHECK waiter %0d", woke);
    if (!woke) $fatal(1, "merged event did not wake the new waiter");
    $finish;
  end
endmodule

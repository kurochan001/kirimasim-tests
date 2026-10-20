/*
:name: test_event_null_compare
:description: Event variables compare equal when they share one event, an event variable is false as a condition only when it is null, triggering a null event has no effect, and assigning null to one variable leaves the event of another (IEEE 1800-2023 Section 15.5.5.3)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.5.5.3 15.5.5.2 15.5.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_null_compare.expected
*/
// IEEE 1800-2023 §15.5.5.3: == and === compare whether two event variables
// refer to the same event, != and !== the opposite, and an event variable
// used as a condition is 0 only when it is null. e1 and e2 are different
// events until e2 = e1 merges them (15.5.5.1). §15.5.5.2: e3 = null breaks
// its link to its event, and -> e3 then has no effect. Assigning null to e2
// does not change e1: the -> e1 at 2 still wakes the process waiting on e1.

module test_event_null_compare;
  event e1, e2, e3;
  int woke = 0;

  initial begin
    $display("e1 == e2: %0d, e1 != e2: %0d, e1 === e1: %0d", e1 == e2, e1 != e2, e1 === e1);
    e2 = e1;
    $display("after e2 = e1: e1 == e2: %0d, e1 !== e2: %0d", e1 == e2, e1 !== e2);
    $display("e3 as a condition: %0d", e3 ? 1 : 0);
    e3 = null;
    $display("after e3 = null: e3 as a condition: %0d, e3 == null: %0d", e3 ? 1 : 0, e3 == null);
    -> e3;
    e2 = null;
    $display("after e2 = null: e1 == null: %0d, e2 == null: %0d", e1 == null, e2 == null);
    fork
      begin @e1; woke++; end
    join_none
    #2 -> e1;
    #1 $display("t=%0d: the waiter of e1 woke %0d time(s)", $time, woke);
  end
endmodule

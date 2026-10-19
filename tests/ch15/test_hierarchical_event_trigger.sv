/*
:name: test_hierarchical_event_trigger
:description: Named events of another instance triggered and waited for through hierarchical names, with the triggered property (IEEE 1800-2023 Section 15.5.1)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.5.1 15.5.3 23.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_hierarchical_event_trigger.expected
*/
// IEEE 1800-2023 §15.5.1: -> triggers a named event, which resumes the
// processes waiting for it. The event can be named through a hierarchical
// name (23.6): the top module triggers u.go, which a process in u waits
// for, and waits for u.done, which u triggers. §15.5.3: u.done.triggered
// read through the hierarchical name is true for the rest of the time step
// in which the event was triggered.

module event_peer;
  event go, done;
  int hits = 0;

  initial begin
    @(go);
    hits++;
    #1 -> done;
  end
endmodule

module test_hierarchical_event_trigger;
  event_peer u ();

  initial begin
    #5 -> u.go;
    @(u.done);
    $display("t=%0d u.hits=%0d u.done.triggered=%0d", $time, u.hits, u.done.triggered);
    #1 $display("t=%0d u.done.triggered=%0d", $time, u.done.triggered);
  end
endmodule

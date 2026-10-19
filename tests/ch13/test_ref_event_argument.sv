/*
:name: test_ref_event_argument
:description: An event passed by reference to a task is the caller's event: triggering the formal wakes processes waiting for the actual (IEEE 1800-2023 Section 13.5.2)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.2 15.5.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ref_event_argument.expected
*/
// IEEE 1800-2023 §13.5.2: a ref argument refers to the caller's variable
// itself. For a named event passed by reference, triggering the formal with
// -> (15.5.1) triggers the caller's event, so a process waiting for that
// event resumes, and so does a process that the task waits on through the
// formal.

module test_ref_event_argument;
  event go, done;
  int hits = 0;

  task automatic fire(ref event ev);
    -> ev;
  endtask

  task automatic wait_for(ref event ev);
    @(ev);
    $display("t=%0d wait_for resumes", $time);
  endtask

  initial begin
    @(go);
    hits++;
    $display("t=%0d @(go) resumes, hits=%0d", $time, hits);
  end

  initial wait_for(done);

  initial begin
    #1 fire(go);
    #1 fire(done);
  end
endmodule

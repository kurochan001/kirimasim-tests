/*
:name: test_process_self_status_kill
:description: std::process::self() returns the running process, status() reports RUNNING, WAITING, FINISHED and KILLED over a process's life, the state enumeration has the five names in the order G.6 gives with the values 0 to 4, and kill() ends a process and its descendants before it returns (IEEE 1800-2023 Section 9.7, G.6)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.7 G.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_process_self_status_kill.expected
*/
// IEEE 1800-2023 §9.7: self() returns a handle to the process that calls it,
// status() returns its state, and kill() forcibly terminates a process and all
// its descendant subprocesses before it returns. G.6 gives the prototypes of
// the class and the order of the state enumeration, whose first name has the
// value 0 and whose names count up from there (6.19.1).
//
// The test's own process is RUNNING while it executes its first statements.
// A child that waits on a delay is WAITING there, and is FINISHED once the
// delay has passed and the child has marked its end. A second child, which
// waits 100 time units and then marks itself, is KILLED by kill() at once, and
// its mark is still 0 long after its delay would have expired. The child
// handles are read only after a delay, so each has been given to the parent
// before it is used.

module test_process_self_status_kill;
  int mark_paced = 0;
  int mark_killed = 0;
  std::process paced;
  std::process victim;

  initial begin
    std::process here = std::process::self();
    $display("self is the running process %0d",
             here.status() == std::process::RUNNING);
    $display("state values %0d %0d %0d %0d %0d", std::process::FINISHED,
             std::process::RUNNING, std::process::WAITING,
             std::process::SUSPENDED, std::process::KILLED);

    fork
      begin
        paced = std::process::self();
        #10 mark_paced = 1;
      end
    join_none

    #1;
    $display("paced waits %0d", paced.status() == std::process::WAITING);
    #11;
    $display("paced marked %0d, finished %0d", mark_paced,
             paced.status() == std::process::FINISHED);

    fork
      begin
        victim = std::process::self();
        #100 mark_killed = 1;
      end
    join_none

    #1;
    $display("victim waits %0d", victim.status() == std::process::WAITING);
    victim.kill();
    $display("victim killed %0d", victim.status() == std::process::KILLED);
    #110;
    $display("marks after the victim's delay %0d", mark_killed);
    $finish;
  end
endmodule

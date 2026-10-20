/*
:name: test_process_kill_self
:description: A process that calls kill() on itself ends at once with the status KILLED, as one killed by another process does (IEEE 1800-2023 Section 9.7)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_process_kill_self.expected
*/
// IEEE 1800-2023 §9.7: kill() forcibly terminates the process it is called
// on, and the process status becomes KILLED. When a process calls kill() on
// its own handle, it is terminated there: the statements after the call do
// not run. A process killed by another process while it waits in a delay
// ends the same way.

module test_process_kill_self;
  process p, q;
  int after_self = 0, after_other = 0;

  initial begin
    fork
      begin
        p = process::self();
        p.kill();
        after_self = 1;
      end
      begin
        q = process::self();
        #5 after_other = 1;
      end
    join_none
    #1 q.kill();
    #10;
    $display("self-killed: after_self=%0d status=%s", after_self, p.status().name());
    $display("killed by another: after_other=%0d status=%s", after_other, q.status().name());
  end
endmodule

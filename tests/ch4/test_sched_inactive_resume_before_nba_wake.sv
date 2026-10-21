/*
:name: test_sched_inactive_resume_before_nba_wake
:description: A process resumed from #0 runs before a process woken by the nonblocking update of the same time step (IEEE 1800-2023 Section 4.5)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.5 4.4.2.3 4.4.2.4 9.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_inactive_resume_before_nba_wake.expected
*/
// IEEE 1800-2023 §4.5: the Inactive region is moved into the Active region
// before the NBA region is. The parent resumes from #0 (§4.4.2.3) and prints
// the old value; only then does the NBA region (§4.4.2.4) update x and wake the
// child that waits for it.

module test_sched_inactive_resume_before_nba_wake;
  int x = 0;
  initial begin
    fork
      begin
        @(x);
        $display("child woke: x=%0d", x);
      end
    join_none
    #0;
    x <= 1;
    #0 $display("parent after #0: x=%0d", x);
  end
endmodule

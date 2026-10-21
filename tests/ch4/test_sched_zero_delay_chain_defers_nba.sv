/*
:name: test_sched_zero_delay_chain_defers_nba
:description: A process that keeps resuming from #0 runs before the nonblocking update of its time step, however many times it does so (IEEE 1800-2023 Section 4.5)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.5 4.4.2.3 4.4.2.4 10.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_zero_delay_chain_defers_nba.expected
*/
// IEEE 1800-2023 §4.5: in a time step the scheduler moves the Inactive region
// into the Active region while either has events, and reaches the NBA region
// (§4.4.2.4) only when both are empty. Each #0 puts the process in the Inactive
// region (§4.4.2.3), so all three displays come before the update of x <= 1,
// which the display one time unit later shows.

module test_sched_zero_delay_chain_defers_nba;
  int x = 0;
  initial begin
    x <= 1;
    repeat (3) begin
      #0 $display("after #0: x=%0d", x);
    end
    #1 $display("next time step: x=%0d", x);
  end
endmodule

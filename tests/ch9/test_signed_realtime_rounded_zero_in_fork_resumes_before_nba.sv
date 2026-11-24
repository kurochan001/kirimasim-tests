/*
:name: test_signed_realtime_rounded_zero_in_fork_resumes_before_nba
:description: A fork child whose signed realtime delay rounds to zero runs before nonblocking updates
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.1 3.14.1 4.4.2.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_signed_realtime_rounded_zero_in_fork_resumes_before_nba.expected
*/
`timescale 1ns/1ns
module test_signed_realtime_rounded_zero_in_fork_resumes_before_nba;
  int state;
  task automatic attempt(input realtime duration);
    time started;
    started = $time;
    state = 3;
    state <= 9;
    fork : bounded_delay
      begin
        #(duration);
        $display("value=%0.2f elapsed=%0d first=%0d", duration, $time - started, state);
      end
      begin
        #2;
        $display("value=%0.2f not seen by 2", duration);
      end
    join_any
    disable bounded_delay;
    #1 $display("after=%0d", state);
  endtask
  initial begin
    #2;
    attempt(-0.25);
    attempt(0.25);
    attempt(0.75);
    $finish(0);
  end
endmodule

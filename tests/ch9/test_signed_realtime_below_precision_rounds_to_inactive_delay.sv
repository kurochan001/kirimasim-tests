/*
:name: test_signed_realtime_below_precision_rounds_to_inactive_delay
:description: Small negative and positive realtime values round to zero delay and resume in the inactive region
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.1 3.14.1 4.4.2.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_signed_realtime_below_precision_rounds_to_inactive_delay.expected
*/
`timescale 1ns/1ns
module test_signed_realtime_below_precision_rounds_to_inactive_delay;
  int state;

  task automatic attempt(input realtime interval);
    time started;
    started = $time;
    state = 3;
    state <= 9;
    #(interval);
    $display("value=%0.2f elapsed=%0d first=%0d", interval, $time - started, state);
    #1 $display("after=%0d", state);
  endtask

  initial #20 begin
    $display("delay did not complete");
    $finish(0);
  end

  initial begin
    #2;
    state = 3;
    state <= 9;
    #0 $display("literal zero first=%0d", state);
    #1 $display("literal zero after=%0d", state);
    attempt(-0.25);
    attempt(0.25);
    attempt(0.75);
    $finish(0);
  end
endmodule

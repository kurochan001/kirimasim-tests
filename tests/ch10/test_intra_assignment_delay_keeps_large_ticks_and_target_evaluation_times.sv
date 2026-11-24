/*
:name: test_intra_assignment_delay_keeps_large_ticks_and_target_evaluation_times
:description: Large intra-assignment delays preserve the exact tick, original value, and different blocking and nonblocking target evaluation times
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.1 10.4.2 9.4.5 4.9.3 4.9.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_intra_assignment_delay_keeps_large_ticks_and_target_evaluation_times.expected
*/
`timescale 1ps/1ps

module test_intra_assignment_delay_keeps_large_ticks_and_target_evaluation_times;
  localparam time BASE = 64'd9007199254740992;
  localparam time DELAY = 64'd9007199254740993;
  bit [7:0] blocking_dest[2], nonblocking_dest[2];
  bit [7:0] payload = 8'ha5;
  int target = 0;
  time blocking_done = 0, nonblocking_done = 0, queued = 0;

  initial begin
    #5;
    nonblocking_dest[target] <= #(DELAY) payload;
    queued = $time;
    blocking_dest[target] = #(DELAY) payload;
    blocking_done = $time;
  end

  initial begin
    #6;
    target = 1;
    payload = 8'h59;
  end

  always @(nonblocking_dest[0] or nonblocking_dest[1])
    if (nonblocking_dest[0] != 0 || nonblocking_dest[1] != 0)
      nonblocking_done = $time;

  initial begin
    #(BASE);
    repeat (4) #1;
    $display("before blocking=%h %h nonblocking=%h %h",
             blocking_dest[0], blocking_dest[1], nonblocking_dest[0], nonblocking_dest[1]);
    repeat (4) #1;
    $display("after blocking=%h %h nonblocking=%h %h",
             blocking_dest[0], blocking_dest[1], nonblocking_dest[0], nonblocking_dest[1]);
    $display("queued=%0d blocking-time=%0d nonblocking-time=%0d",
             queued, blocking_done, nonblocking_done);
  end
endmodule

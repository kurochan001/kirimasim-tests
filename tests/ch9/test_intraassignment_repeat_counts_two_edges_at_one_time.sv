/*
:name: test_intraassignment_repeat_counts_two_edges_at_one_time
:description: Repeat controls count two different edges in one time slot for both blocking and nonblocking assignments
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.5 10.4.1 10.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_intraassignment_repeat_counts_two_edges_at_one_time.expected
*/
`timescale 1ns/1ns
module test_intraassignment_repeat_counts_two_edges_at_one_time;
  bit phi1, phi2 = 1;
  int requested = 2, payload = 31;
  int blocked_value = 0, queued_value = 0;
  time caller_returned = 0, blocking_write = 0, queued_write = 0;

  initial begin
    #1;
    blocked_value = repeat (requested) @(posedge phi1 or negedge phi2) payload;
    blocking_write = $time;
  end

  initial begin
    #1;
    queued_value <= repeat (requested) @(posedge phi1 or negedge phi2) payload;
    caller_returned = $time;
  end

  always @(queued_value)
    if (queued_value != 0)
      queued_write = $time;

  initial begin
    #2;
    requested = 4;
    payload = 99;
    #2;
    phi1 = 1;
    phi2 = 0;
    #0;
    $display("before NBA blocked=%0d queued=%0d caller=%0d",
             blocked_value, queued_value, caller_returned);
    #1;
    $display("stored=%0d/%0d at=%0d/%0d", blocked_value, queued_value,
             blocking_write, queued_write);
    $finish(0);
  end
endmodule

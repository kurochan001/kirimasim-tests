/*
:name: test_evcd_close_records_final_time_when_queue_drains
:description: Extended VCD records the end time when the event queue drains
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.3.6.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_evcd_close_records_final_time_when_queue_drains.expected
:expected_exit: 0
*/
`timescale 1ns/1ns
module evcd_queue_drain_leaf(input wire data, output wire mirror);
  assign mirror = data;
endmodule

module test_evcd_close_records_final_time_when_queue_drains;
  bit source;
  wire observation;
  evcd_queue_drain_leaf trace(source, observation);

  initial begin
    $dumpports(trace, "drained.evcd");
    #4 source = 1;
    #17 $display("event queue drains at %0d", $time);
  end
endmodule

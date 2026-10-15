/*
:name: test_edge_time_round
:description: $time rounds the current time to the module's time unit (IEEE 1800-2023 Sections 20.3.1 and 3.14.2.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.3.1 3.14.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_edge_time_round.expected
*/
module test_edge_time_round;
  timeunit 1ns/1ps;
  time timestamps[$];

  initial begin
    #0.49ns;
    timestamps.push_back($time);
    #0.51ns;
    timestamps.push_back($time);

    if (timestamps[0] !== 0) $fatal(1, "$time at 0.49 ns should round to 0");
    if (timestamps[1] !== 1) $fatal(1, "$time at 1.00 ns should be 1");

    $display("PASS: timeunit/timeprecision rounding verified");
    $finish;
  end
endmodule

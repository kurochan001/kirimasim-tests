/*
:name: test_time_literal_scaled_to_unit
:description: A time literal in a delay is scaled to the module's time unit, and $time rounds the time to a whole number of units while $realtime keeps the fraction (IEEE 1800-2023 Section 5.8)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.8 22.7 20.3.1 20.3.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_time_literal_scaled_to_unit.expected
*/
// IEEE 1800-2023 §5.8: a time literal such as 26ns is a real value scaled to
// the current time unit, here 10ns, so #26ns is a delay of 2.6 units. $time
// rounds the time to an integer number of units (20.3.1), 3, and $realtime
// gives 2.6 (20.3.3). Then #14ns (1.4 units) brings the time to 4.0 units.

`timescale 10ns/1ns

module test_time_literal_scaled_to_unit;
  initial begin
    #26ns $display("time=%0d realtime=%0.1f", $time, $realtime);
    #14ns $display("time=%0d realtime=%0.1f", $time, $realtime);
  end
endmodule

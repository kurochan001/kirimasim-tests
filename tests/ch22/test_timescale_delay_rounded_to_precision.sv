/*
:name: test_timescale_delay_rounded_to_precision
:description: Delays are rounded to the time precision of the module before they are used, so a fraction finer than the precision is lost (IEEE 1800-2023 Section 22.7)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.7 20.3.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timescale_delay_rounded_to_precision.expected
*/
// IEEE 1800-2023 §22.7: the time precision says how delay values are rounded
// before they are used. With a unit of 1ns and a precision of 100ps, #1.26
// waits 1.3ns, #0.04 waits nothing (0.04ns rounds to 0), and #2.71 waits 2.7ns;
// $realtime gives the time in units of 1ns (20.3.3).

`timescale 1ns/100ps

module test_timescale_delay_rounded_to_precision;
  initial begin
    #1.26 $display("after #1.26: %0.2f", $realtime);
    #0.04 $display("after #0.04: %0.2f", $realtime);
    #2.71 $display("after #2.71: %0.2f", $realtime);
  end
endmodule

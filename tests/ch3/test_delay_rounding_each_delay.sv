/*
:name: test_delay_rounding_each_delay
:description: Each delay is rounded to the time precision before it is scheduled, so three delays of 0.16 units advance 0.6 and not 0.5 (IEEE 1800-2023 Section 3.14.1)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.1 3.14.2.1 20.3.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_delay_rounding_each_delay.expected
*/
// IEEE 1800-2023 §3.14.1: a delay is rounded to the time precision of the
// design element that contains it when the delay control runs, so the sum of
// a loop of delays is the sum of the rounded delays, not the rounded sum.
// §3.14.2.1: the `timescale gives a unit of 1ns and a precision of 100ps, so
// #0.16 rounds to 0.2 and three of them advance 0.6; #0.44 rounds to 0.4 and
// ends at 1.0. §20.3.3: $realtime reports the times.

`timescale 1ns / 100ps

module test_delay_rounding_each_delay;
  initial begin
    repeat (3) #0.16;
    $display("%0.1f", $realtime);
    #0.44 $display("%0.1f", $realtime);
  end
endmodule

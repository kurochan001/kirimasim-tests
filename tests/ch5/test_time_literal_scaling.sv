/*
:name: test_time_literal_scaling
:description: Time literals are real values scaled to the current time unit, in expressions and in delays (IEEE 1800-2023 Section 5.8)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.8 3.14.2.1 20.3.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_time_literal_scaling.expected
*/
// IEEE 1800-2023 §5.8: a time literal is a number followed directly by a time
// unit, and its value is a realtime value scaled to the current time unit. With
// a time unit of 1 ns, 1.5ns is 1.5, 2us is 2000.0 and 250ps is 0.25, and a
// delay written with a time literal waits that long (3.14.2.1). $realtime
// returns the current time in the same unit (20.3.3).

`timescale 1ns/1ps

module test_time_literal_scaling;
  realtime r1, r2, r3;

  initial begin
    r1 = 1.5ns;
    r2 = 2us;
    r3 = 250ps;
    $display("r1=%0.3f r2=%0.3f r3=%0.3f", r1, r2, r3);
    #1.5ns;
    $display("after #1.5ns: %0.3f", $realtime);
    #250ps;
    $display("after #250ps: %0.3f", $realtime);
    #1;
    $display("after #1: %0.3f", $realtime);
  end
endmodule

/*
:name: test_global_pulse_defaults
:description: without pulse limit options a path rejects pulses shorter than its delay and passes longer ones (IEEE 1800-2023 Section 30.7.2)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.7 30.7.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_global_pulse_defaults.expected
*/
// Both global pulse percentages default to 100 percent of each
// transition delay, so the reject and error limits of a path are its
// delay. A pulse shorter than the delay is rejected, a pulse of the
// delay passes; there is no x region, because the error limit equals
// the reject limit.

`timescale 1ns/1ns

module buf1(output y, input a);
  buf (y, a);
  specify
    (a => y) = 6;
  endspecify
endmodule

module test_global_pulse_defaults;
  reg a = 0;
  wire y;
  buf1 u(y, a);

  always @(y) if ($time >= 10) $display("%0d: y=%b", $time, y);

  initial begin
    #10 a = 1;
    #5 a = 0;      // 15: a pulse of 5, rejected
    #10 a = 1;     // 25
    #6 a = 0;      // 31: a pulse of 6, passed: y at 31 and 37
    #10 $finish;
  end
endmodule

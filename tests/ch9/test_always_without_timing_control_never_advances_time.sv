/*
:name: test_always_without_timing_control_never_advances_time
:description: an always procedure with no timing control repeats its statement without ever letting simulation time advance, so a delayed process never runs and a $finish in the loop ends the simulation at time 0 (IEEE 1800-2023 Section 9.2.2.1)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_without_timing_control_never_advances_time.expected
*/
// IEEE 1800-2023 §9.2.2.1: an always procedure repeats its statement, and
// when the statement contains no control that lets simulation time advance,
// the loop deadlocks the simulation in zero time; no time advance is implied
// between the repetitions. The always procedure here has no delay, event or
// wait control: it counts its repetitions and calls $finish on the 1000th.
// The other process waits for #1. Time cannot reach 1 while the always
// procedure keeps running at time 0, so that process never prints, and both
// the always procedure and the final procedure see time 0 and 1000
// repetitions. A tool that advanced time between repetitions would print a
// later time, and the delayed process would print before the 1000th
// repetition.
//
// The standard does not make such an always procedure an error. Icarus
// Verilog 13.0 rejects it at elaboration ("always process does not have any
// delay"). The 5.054 release of Verilator prints the first line, but after
// $finish it keeps evaluating the procedure, stops with a DIDNOTCONVERGE
// error and does not run the final procedure, which $finish has to run
// (§9.2.3, §20.2). The expected output follows the standard.

`timescale 1ns/1ns

module test_always_without_timing_control_never_advances_time;
  int iterations;

  always begin
    iterations++;
    if (iterations == 1000) begin
      $display("repetition %0d at time %0t", iterations, $time);
      $finish;
    end
  end

  initial #1 $display("time advanced to %0t", $time);

  final $display("final at time %0t after %0d repetitions", $time, iterations);
endmodule

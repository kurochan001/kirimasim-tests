/*
:name: test_error_does_not_end_run
:description: $error reports a run-time error but does not stop the simulation, unlike $fatal; the procedures after it keep running (IEEE 1800-2023 Section 20.10)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_error_does_not_end_run.expected
*/
// IEEE 1800-2023 §20.10: $error generates a run-time error, and only $fatal
// ends the simulation; $warning and $info report and go on as well. The
// messages themselves have a tool-specific form and are not compared. The
// standard does not say what exit code a run with errors ends with, so the
// test does not check it.

`timescale 1ns/1ns

module test_error_does_not_end_run;
  initial begin
    $display("start");
    $info("informational");
    $warning("a warning");
    $error("first error");
    $display("after first error");
    #1 $error("second error");
    $display("t=%0d: after second error", $time);
  end
endmodule

/*
:name: test_vpi_error_callback_runtime_errors
:description: A cbError callback runs once for each run-time error of the simulation, here each $error, and not for a run-time warning or message (IEEE 1800-2023 Section 38.36.3)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_error_callback_runtime_errors.c
:expected_stdout: @test_vpi_error_callback_runtime_errors.expected
*/
// IEEE 1800-2023 §38.36.3: cbError is an action callback, which every VPI tool
// has, for a run-time error of the simulation. A startup routine may register
// it (36.10.2). §20.10: $error generates a run-time error, $warning a run-time
// warning and $info a run-time message of no specific severity; none of them
// ends the simulation.
// The startup routine registers cbError and cbEndOfSimulation. The design calls
// $info and $warning at 0, $error at 1 and at 2, and $display at 3. The
// cbError routine records the time of each call; when the simulation ends, the
// application prints the number of calls and their times: two, at 1 and 2. The
// messages of the severity tasks themselves are not compared. Icarus Verilog
// 13.0 and Verilator 5.052 never call the cbError callback here (0 calls), so
// :oracle: names no simulator.

`timescale 1ns/1ns

module test_vpi_error_callback_runtime_errors;
  initial begin
    $info("a message of no specific severity");
    $warning("a run-time warning");
    #1 $error("the first run-time error");
    #1 $error("the second run-time error");
    #1 $display("%0t: the simulation goes on after the errors", $time);
  end
endmodule

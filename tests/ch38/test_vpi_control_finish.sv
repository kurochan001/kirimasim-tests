/*
:name: test_vpi_control_finish
:description: vpi_control(vpiFinish, 0) called from a callback ends the simulation as $finish(0) would, and cbEndOfSimulation callbacks still run (IEEE 1800-2023 Section 38.4)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.4 38.36.2 38.36.3 20.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_control_finish.c
:expected_stdout: @test_vpi_control_finish.expected
*/
// IEEE 1800-2023 §38.4: vpi_control(vpiFinish, n) makes $finish(n) run when the
// application routine returns (20.2); with 0 it prints no message.
// $vt_finish_after(25) registers a cbAfterDelay callback (38.36.2) that does
// this 25 time units later, and a cbEndOfSimulation callback (38.36.3) that
// prints when the simulation ends. The loop prints every 10, so its lines at 10
// and 20 appear, and none after 25.

`timescale 1ns/1ns

module test_vpi_control_finish;
  integer k;

  initial begin
    $vt_finish_after(25);
    for (k = 0; k < 10; k = k + 1)
      #10 $display("%0d: still running", $time);
  end
endmodule

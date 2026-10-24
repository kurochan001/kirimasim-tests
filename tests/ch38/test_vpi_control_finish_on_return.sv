/*
:name: test_vpi_control_finish_on_return
:description: vpi_control(vpiFinish, 0) returns 1 and lets the calling routine go on, $finish is executed when the routine returns so that no later event runs, and vpi_control with an operation that is not defined returns 0 (IEEE 1800-2023 Section 38.4)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.4 20.2 38.36.2 38.36.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_control_finish_on_return.c
:expected_stdout: @test_vpi_control_finish_on_return.expected
*/
// IEEE 1800-2023 §38.4: vpi_control takes a PLI_INT32 operation and the
// arguments of that operation and returns 1 on success and 0 on failure.
// vpiFinish, with one integer argument, the diagnostic level of $finish
// (20.2), makes $finish run when the application routine returns. The
// application registers, at the start of the simulation, a cbAfterDelay
// callback of 5 (38.36.2) and a cbEndOfSimulation callback (38.36.3). The
// routine of the first calls vpi_control with an operation number that
// 38.4 does not define (12345), then with vpiFinish and 0, which prints no
// message, and prints both results after the second call, before it
// returns. The design prints at 4 and would print at 6 and 7; the simulation
// ends at 5.
// Under Verilator 5.052, vpi_control prints a $finish message with an empty
// file name, although $finish with 0 prints nothing (20.2).

`timescale 1ns/1ns

module test_vpi_control_finish_on_return;
  initial begin
    #4 $display("4: design running");
    #2 $display("6: design still running");
  end

  initial #7 $display("7: design still running");
endmodule

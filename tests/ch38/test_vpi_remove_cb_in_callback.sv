/*
:name: test_vpi_remove_cb_in_callback
:description: vpi_remove_cb returns 1 when a value change callback removes itself in its own routine, which then runs no more while another callback on the same variable goes on, and when a callback routine removes a pending time callback and one of two end of simulation callbacks, which never run (IEEE 1800-2023 Section 38.39)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.39 38.36.1 38.36.2 38.36.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_remove_cb_in_callback.c
:expected_stdout: @test_vpi_remove_cb_in_callback.expected
*/
// IEEE 1800-2023 §38.39: vpi_remove_cb removes a callback registered with
// vpi_register_cb and returns 1 on success. At the start of the simulation
// the application places two cbValueChange callbacks on r (38.36.1), once and
// every, a cbAfterDelay callback for time 5 (38.36.2), and two
// cbEndOfSimulation callbacks (38.36.3). once removes itself the first time it
// runs; every runs for each of the three changes of r, and at its second run,
// at time 2, removes the time callback and the second end of simulation
// callback. The first end
// of simulation callback prints the counts, as the order of the two value
// change callbacks of one change is not fixed.

`timescale 1ns/1ns

module test_vpi_remove_cb_in_callback;
  bit [3:0] r;

  initial begin
    #1 r = 4'd1;
    #1 r = 4'd2;
    #1 r = 4'd3;
    #1 $display("design: r=%0d", r);
  end
endmodule

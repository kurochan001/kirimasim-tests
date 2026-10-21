/*
:name: test_vpi_release_handle_keeps_object
:description: vpi_release_handle returns 1 for a callback handle and an object handle, and releasing them changes neither the callback, which goes on reporting changes, nor the object, which can be found and read again (IEEE 1800-2023 Section 38.38)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.38 37.2.2 38.36.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_release_handle_keeps_object.c
:expected_stdout: @test_vpi_release_handle_keeps_object.expected
*/
// IEEE 1800-2023 §38.38: vpi_release_handle frees what the tool allocated for
// a handle and returns 1 on success. §37.2.2: it releases the handle only;
// a callback is removed by vpi_remove_cb, which releases its handle as part of
// the removal. At the start of the simulation the application places a
// cbValueChange callback on r (38.36.1) and releases the callback handle and
// the handle to r. It then gets r again by name and reads it, and the callback
// still reports the two changes of r, with the time of each (38.36.1). The
// time that Verilator 5.052 passes in the s_cb_data of the callback is 0.

`timescale 1ns/1ns

module test_vpi_release_handle_keeps_object;
  bit [7:0] r;

  initial begin
    #1 r = 8'd3;
    #1 r = 8'd4;
    #1 $display("design: r=%0d", r);
  end
endmodule

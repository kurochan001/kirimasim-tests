/*
:name: test_vpi_release_remove_signatures
:description: vpi_release_handle and vpi_remove_cb take a vpiHandle and return PLI_INT32, return 1 for a valid object handle and for a callback that is removed, and the removed callback is not called again (IEEE 1800-2023 Sections 38.38 and 38.39)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.38 38.39 37.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_release_remove_signatures.c
:expected_stdout: @test_vpi_release_remove_signatures.expected
*/
// IEEE 1800-2023 §38.38: vpi_release_handle(vpiHandle obj) frees the resources
// of a valid handle and returns PLI_INT32 1 on success, 0 on failure.
// §38.39: vpi_remove_cb(vpiHandle cb_obj) removes a callback registered with
// vpi_register_cb and returns PLI_INT32 1 on success, 0 on failure; after the
// removal the callback is not called again (§37.2.2: the removal also
// releases the callback handle).
//
// At the start of the simulation the application registers a cbValueChange
// callback on r and keeps both handles. r gets 3 at time 1. At time 2 the
// application removes the callback, releases the handle to r and prints both
// results. r gets 4 at time 3, which must give no callback; the application
// prints the number of callbacks and the type checks at time 4.

`timescale 1ns/1ns

module test_vpi_release_remove_signatures;
  int r;

  initial begin
    #1 r = 3;
    #2 r = 4;
    #1 $finish;
  end
endmodule

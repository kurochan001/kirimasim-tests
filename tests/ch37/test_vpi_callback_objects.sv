/*
:name: test_vpi_callback_objects
:description: vpi_iterate(vpiCallback, obj) gives the callbacks registered on an object, and vpi_iterate(vpiCallback, NULL) those not related to an object; vpi_get_cb_info returns the reason and object of a callback, and a removed callback is no longer iterated (IEEE 1800-2023 Section 37.80)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.80 38.4 38.30 38.36.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_callback_objects.c
:expected_stdout: @test_vpi_callback_objects.expected
*/
// IEEE 1800-2023 §37.80: callback objects are iterated with vpiCallback from
// the object they are registered on, such as an expression, and, for those
// not related to an object, from NULL (detail 2); vpi_get_cb_info (§38.4)
// returns the s_cb_data of a callback (detail 1). $vt_register registers a
// value change callback (§38.36.1) on w and one on r, and an end of
// simulation callback; $vt_callbacks then iterates them, removes the one on r
// with vpi_remove_cb (§38.30) and iterates r again. r, and with it w,
// changes once, at 2.

`timescale 1ns/1ns

module test_vpi_callback_objects;
  logic r = 0;
  wire w;

  assign w = r;

  initial begin
    #1 $vt_register;
    #1 r = 1;
    #1 $vt_callbacks;
  end
endmodule

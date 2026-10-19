/*
:name: test_vpi_value_change_event
:description: A cbValueChange callback on a named event runs each time the event is triggered, and its value field is NULL because an event has no value (IEEE 1800-2023 Section 38.36.1)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1 15.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_value_change_event.c
:expected_stdout: @test_vpi_value_change_event.expected
*/
// IEEE 1800-2023 §38.36.1: a cbValueChange callback can be placed on a named
// event, and it is called when the event is triggered (15.5.1). An event has no
// value, so the value field of the s_cb_data passed to the callback is NULL.
// $vt_watch registers the callback at time 1, and the event is triggered at 5
// and 10, and the value format asked for at registration is vpiBinStrVal.
// Icarus Verilog 13.0 passes a value structure for an event, and Verilator
// 5.052 does not support user-defined system tasks.

`timescale 1ns/1ns

module test_vpi_value_change_event;
  event ev;

  initial begin
    #1 $vt_watch(ev);
    #4 -> ev;
    #5 -> ev;
  end
endmodule

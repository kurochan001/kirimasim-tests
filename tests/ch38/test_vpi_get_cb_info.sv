/*
:name: test_vpi_get_cb_info
:description: vpi_get_cb_info fills an s_cb_data structure with the reason, routine and user data of a simulation callback, from the handle that vpi_register_cb returned (IEEE 1800-2023 Section 38.8)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.8 38.36 38.36.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_get_cb_info.c
:expected_stdout: @test_vpi_get_cb_info.expected
*/
// IEEE 1800-2023 §38.8: vpi_get_cb_info returns the information of a
// simulation callback in an s_cb_data structure that the application
// provides. $vt_place registers a cbAfterDelay callback with a delay of 5
// (38.36.2) and its own user data, and reads the information back at once; the
// callback runs at time 5.

`timescale 1ns/1ns

module test_vpi_get_cb_info;
  initial begin
    $vt_place;
    #10 $display("t=%0d: done", $time);
  end
endmodule

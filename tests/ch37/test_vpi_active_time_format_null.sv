/*
:name: test_vpi_active_time_format_null
:description: Before $timeformat is called, vpi_handle(vpiActiveTimeFormat, NULL) returns NULL, and after the call it returns the $timeformat system task call (IEEE 1800-2023 Section 37.82)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.82 21.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_active_time_format_null.c
:expected_stdout: @test_vpi_active_time_format_null.expected
*/
// IEEE 1800-2023 §37.82: the vpiActiveTimeFormat relation of the NULL
// reference gives the active time format, which is a system task call. If
// $timeformat() has not been called, the relation returns NULL (detail 1,
// where the text calls the constant vpiActiveFormat). The design asks before
// calling $timeformat (21.2.3) and again after it, and the names of the two
// states are sorted.

`timescale 1ns/1ns

module test_vpi_active_time_format_null;
  initial begin
    $vt_show("before");
    #1 $timeformat(-9, 2, " ns", 10);
    $vt_show("after");
  end
endmodule

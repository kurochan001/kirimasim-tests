/*
:name: test_vpi_callback_suppress_value
:description: A cbValueChange callback registered with vpiSuppressVal delivers no value, and one registered with vpiSuppressTime gets no simulation time (IEEE 1800-2023 Section 38.36.1)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1 38.36
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_callback_suppress_value.c
:expected_stdout: @test_vpi_callback_suppress_value.expected
*/
// IEEE 1800-2023 §38.36.1: the value format of a callback request is set to
// one of the formats of Table 38-5, or to vpiSuppressVal when the application
// does not need the value, and the time type to vpiSuppressTime when it does
// not need the time. The callback then delivers no value.
//
// At time 1 $vt_watch places a cbValueChange callback on v with the value
// format vpiSuppressVal and the time type vpiSuppressTime. v gets 9 at
// time 2. The callback prints what it received, and $vt_report prints the
// counts at time 4.

`timescale 1ns/1ns

module test_vpi_callback_suppress_value;
  int v;

  initial begin
    #1 $vt_watch;
  end

  initial begin
    #2 v = 9;
    #2 $vt_report;
  end
endmodule

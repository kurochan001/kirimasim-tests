/*
:name: test_vpi_value_change_callback
:description: A cbValueChange callback runs after each change of a variable or a net, with the time and value in the requested formats, and not for an assignment of the same value (IEEE 1800-2023 Section 38.36.1)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1 38.36 38.15
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_value_change_callback.c
:expected_stdout: @test_vpi_value_change_callback.expected
*/
// IEEE 1800-2023 §38.36.1: a cbValueChange callback is called after a value
// change of its object, with the time and the value in the formats given at
// registration, here vpiSimTime and vpiBinStrVal. $vt_watch registers one on
// each argument at time 1. r gets 3 at 5, the same 3 at 10 (no change) and a at
// 15; the net w, ~r, follows it in the same time step.

`timescale 1ns/1ns

module test_vpi_value_change_callback;
  reg [3:0] r;
  wire [3:0] w;

  assign w = ~r;

  initial begin
    #1 $vt_watch(r, w);
    #4 r = 4'h3;
    #5 r = 4'h3;
    #5 r = 4'ha;
  end
endmodule

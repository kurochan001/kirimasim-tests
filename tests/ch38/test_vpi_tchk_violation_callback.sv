/*
:name: test_vpi_tchk_violation_callback
:description: A cbTchkViolation callback runs for each timing check violation, with the reason cbTchkViolation and the violated timing check as its object, and not for changes outside the timing check windows (IEEE 1800-2023 Section 38.36.3, 31.3.1, 31.3.2)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.3 31.3.1 31.3.2 37.40
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_tchk_violation_callback.c
:expected_stdout: @test_vpi_tchk_violation_callback.expected
*/
// IEEE 1800-2023 §38.36.3: cbTchkViolation is an action callback, which every
// VPI tool has, for a timing check violation; the routine gets an s_cb_data
// whose reason is cbTchkViolation and whose obj is a handle to the timing
// check. §37.40: the type of that object is vpiTchk, and vpiTchkType tells
// which check it is. §31.3.1: $setup(d, posedge clk, 3) reports a violation
// when d changes strictly less than 3 before the clock edge; §31.3.2: $hold(
// posedge clk, d, 2) reports one when d changes at the edge or less than 2
// after it.
//
// d changes exactly 2 after the edge at 10 (no hold violation), 2 before the
// edge at 20 (a setup violation, found at 20), 1 after it (a hold violation,
// at 21), and exactly 3 before the edge at 30 (no setup violation). At the
// start of the simulation, a cbStartOfSimulation callback registers the
// callback with only reason and cb_rtn set (a startup routine may place only
// the reasons of 36.10.2). The callback prints the time, whether the reason
// is cbTchkViolation, and the kind of the timing check its obj denotes;
// $vt_count prints the number of callbacks at the end.
//
// Icarus Verilog 13.0 does not evaluate timing checks and its vpi_user.h
// lacks the vpiTchk constants, and Verilator 5.052 has no timing checks, so
// :oracle: names no simulator.

`timescale 1ns/1ns

module tvc_cell(input clk, input d);
  specify
    $setup(d, posedge clk, 3);
    $hold(posedge clk, d, 2);
  endspecify
endmodule

module test_vpi_tchk_violation_callback;
  reg clk = 0, d = 0;

  tvc_cell u(clk, d);

  initial begin
    #10 clk = 1;
    #2 d = 1;
    #3 clk = 0;
    #3 d = 0;
    #2 clk = 1;
    #1 d = 1;
    #4 clk = 0;
    #2 d = 0;
    #3 clk = 1;
    #5 $vt_count;
  end
endmodule

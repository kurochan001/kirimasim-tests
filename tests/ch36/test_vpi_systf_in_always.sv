/*
:name: test_vpi_systf_in_always
:description: A user-defined system task can be called from an always procedure, and each execution of the procedure calls it (IEEE 1800-2023 Section 36.4)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.4 36.9.1 9.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_in_always.c
:expected_stdout: @test_vpi_systf_in_always.expected
*/
// IEEE 1800-2023 §36.4: a user-defined system task is called like a built-in
// task from any procedural code, so the always procedure calls $vt_tick at
// each rising edge of clk. §9.4.2: the edges are at 5, 15 and 25, but the
// test ends at 16, so the task runs twice. §36.9.1: the application registers
// $vt_tick and $vt_report from vlog_startup_routines.

`timescale 1ns/1ns

module test_vpi_systf_in_always;
  logic clk = 0;

  always #5 clk = ~clk;

  always @(posedge clk)
    if ($time < 16) $vt_tick;

  initial begin
    #16 $vt_report;
    $finish;
  end
endmodule

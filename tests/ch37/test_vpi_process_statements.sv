/*
:name: test_vpi_process_statements
:description: a module gives its processes, initial, always with its always type, and final; their statements give event controls with their condition, delay controls, and assignments with their operator, blocking flag, left and right sides and intra-assignment delay (IEEE 1800-2023 Sections 37.63, 37.64, 37.65, 37.68)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.63 37.64 37.65 37.68 37.59 38.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_process_statements.c
:expected_stdout: @test_vpi_process_statements.expected
*/
// IEEE 1800-2023 §37.63: vpi_iterate(vpiProcess, module) gives the initial,
// final and always procedures, and vpiAlwaysType tells always, always_comb,
// always_ff and always_latch apart; vpiStmt gives the statement. §37.65: an
// event control has vpiCondition, here a posedge operation (§37.59), and its
// statement. §37.68: a delay control has its statement and its delay, read
// with vpi_get_delays (§38.10). §37.64: an assignment has vpiLhs, vpiRhs and
// vpiBlocking; vpiOpType is vpiAssignmentOp for = and <=, and the operator
// for an assignment operator such as +=; an intra-assignment delay is a
// delay control without a statement. The application prints one line per
// process, sorted.

`timescale 1ns/1ns

module test_vpi_process_statements;
  logic clk = 0, d = 0, q, r;
  int acc = 0;

  always @(posedge clk) q <= #2 d;
  always_comb r = d;
  initial #4 acc += 3;
  initial #1 $vt_processes;
  final acc = 0;
endmodule

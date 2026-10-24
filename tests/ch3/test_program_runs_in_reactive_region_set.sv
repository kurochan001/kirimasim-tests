/*
:name: test_program_runs_in_reactive_region_set
:description: The initial procedure and event control of a program run in the Reactive region, after the design's active and nonblocking-update activity of the time step, so the program reads the updated values where a module process of the same time step reads the old ones (IEEE 1800-2023 Section 3.4)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.4 24.3.1 4.4.1 4.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_runs_in_reactive_region_set.expected
*/
// IEEE 1800-2023 §3.4: a program gives the scheduling of its code in the
// reactive region set. §24.3.1: initial procedures of a program are
// scheduled in the Reactive region, and so is a statement of the program that
// waits for a change of a design signal. §4.5: the reactive region set of a
// time step runs only when the active region set (Active, Inactive, NBA) is
// empty, so a program process sees every nonblocking update of the design
// in that time step, also one made in a second NBA pass.
// - time 0: the module schedules a <= 1, which wakes an always procedure
//   that schedules b <= a + 1 (b = 2 in the next NBA pass). The module's own
//   process, still in the Active region, prints the old values 0 0; the
//   program's initial procedure prints 1 2.
// - time 5: a rising clock makes always_ff schedule q <= q + 1. A module
//   process waiting for the same edge runs in the Active region and prints
//   the old q = 0; the program's @(posedge clk) resumes in the Reactive
//   region and prints q = 1.
// Icarus Verilog 13.0 and Verilator 5.052 run the program's processes in the
// Active region and print the old values in the program's lines.

`timescale 1ns/1ns

module test_program_runs_in_reactive_region_set;
  logic [3:0] a = 0, b = 0, q = 0;
  logic clk = 0;

  always @(a) b <= a + 1;
  always_ff @(posedge clk) q <= q + 1;

  initial begin
    a <= 1;
    $display("module t=%0t: a=%0d b=%0d", $time, a, b);
  end

  initial #5 clk = 1;

  initial begin
    @(posedge clk);
    $display("module t=%0t: q=%0d", $time, q);
  end

  reactive_prog p();
endmodule

program reactive_prog;
  initial begin
    $display("program t=%0t: a=%0d b=%0d", $time,
             test_program_runs_in_reactive_region_set.a,
             test_program_runs_in_reactive_region_set.b);
    @(posedge test_program_runs_in_reactive_region_set.clk);
    $display("program t=%0t: q=%0d", $time, test_program_runs_in_reactive_region_set.q);
  end
endprogram

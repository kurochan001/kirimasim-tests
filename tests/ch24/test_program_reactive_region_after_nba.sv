/*
:name: test_program_reactive_region_after_nba
:description: Statements of a program run in the reactive region set, so a program that wakes at the same time as a module sees the values of the nonblocking assignments of that time step, while the module does not (IEEE 1800-2023 Section 24.2)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_reactive_region_after_nba.expected
*/
// IEEE 1800-2023 §24.2: a program provides an entry point to the execution of
// a testbench and a syntactic context that schedules its elements in the
// reactive region set, which follows the active and NBA regions of a time
// step (4.4). At 5 the module makes the nonblocking assignment b <= 1 and
// prints b in its active region, before the NBA region updates b. The program
// also wakes at 5 and prints b in the reactive region, after the update. The
// program line comes second because the reactive region follows the active
// one. Icarus Verilog 13.0 runs the program before the module and the 5.052
// release of Verilator runs it like a module, so neither prints b=1.

`timescale 1ns/1ns

module test_program_reactive_region_after_nba;
  logic b = 1'b0;
  initial #5 b <= 1'b1;
  initial #5 $display("module at 5: b=%b", b);
  prr_tb tb ();
endmodule

program prr_tb;
  initial #5 $display("program at 5: b=%b", test_program_reactive_region_after_nba.b);
endprogram

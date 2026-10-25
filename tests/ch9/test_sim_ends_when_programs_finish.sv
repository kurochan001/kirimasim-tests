/*
:name: test_sim_ends_when_programs_finish
:description: the simulation ends when the initial procedures of all programs have finished, although a child process forked by the program and a module process are still waiting (IEEE 1800-2023 Section 9.6.1)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.1 24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sim_ends_when_programs_finish.expected
*/
// IEEE 1800-2023 §9.6.1: besides ending when no activity is left, the
// simulation also ends when all its programs have finished executing,
// whatever the state of their child processes (24.3: the program ends the
// descendant threads of its initial procedures, and an implicit $finish
// follows).
//
// The program's initial procedure forks a child that waits until time 100
// and ends itself at time 5. A module initial procedure waits until time
// 50. The simulation ends at time 5: the final procedure prints t=5, and
// neither the child nor the module process prints.
//
// Icarus Verilog 13.0 keeps the simulation running after the program has
// ended and prints the module's line at time 50; release 5.052 of Verilator
// does not support a program declared inside a module.

`timescale 1ns/1ns
module test_sim_ends_when_programs_finish;
  initial #50 $display("t=%0t module process still running", $time);

  final $display("final at t=%0t", $time);

  program prog;
    initial begin
      fork
        #100 $display("t=%0t child of the program", $time);
      join_none
      #5 $display("t=%0t program initial ends", $time);
    end
  endprogram
endmodule

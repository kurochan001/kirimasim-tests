/*
:name: test_program_final_after_initial_ends
:description: A program's final procedure runs when the simulation ends, not when the program's initial procedures have ended, and it sees the last values of the program and of the module (IEEE 1800-2023 Sections 24.3 and 9.2.3)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3 9.2.3 23.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_final_after_initial_ends.expected
*/
// IEEE 1800-2023 §24.3: a program may declare a final procedure, and the
// simulation ends when every initial procedure of every program has ended.
// §9.2.3: a final procedure runs when the simulation ends, not when an
// initial procedure of its design element ends. The first initial procedure
// of p_final ends at 2, but another one waits past the end of the test, so
// the program is still running when the module calls $finish at 10, and the
// final procedure runs there. §23.6: it reads the module variable m, which
// the module set to 7 at 5, through a hierarchical reference.

`timescale 1ns/1ns

program p_final;
  int n = 0;

  initial begin
    #2 n = 3;
    $display("%0d: initial procedure ends", $time);
  end

  initial #20 $display("%0d: other initial goes on", $time);

  final $display("%0d: final n=%0d m=%0d", $time, n,
                 test_program_final_after_initial_ends.m);
endprogram

module test_program_final_after_initial_ends;
  int m = 0;

  p_final p();

  initial begin
    #5 m = 7;
    #5 $display("%0d: module ends", $time);
    $finish;
  end
endmodule

/*
:name: test_program_final_procedure
:description: A program may declare a final procedure, which runs when the simulation ends and sees the last values of the program (IEEE 1800-2023 Sections 24.3 and 9.2.3)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3 9.2.3 20.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_final_procedure.expected
*/
// IEEE 1800-2023 §24.3: a program can hold the procedures of a design element,
// including a final procedure. §9.2.3: a final procedure runs once, when the
// simulation ends. §20.2: $finish ends it at 10, after x has become 2, so the
// final procedure prints that value and the module's message at 20 never
// appears.

`timescale 1ns/1ns

program p_final;
  int x = 1;

  initial begin
    #5 x = 2;
    #5 $display("%0d: program ends x=%0d", $time, x);
    $finish;
  end

  final $display("%0d: final x=%0d", $time, x);
endprogram

module test_program_final_procedure;
  initial #20 $display("%0d: module still running", $time);
endmodule

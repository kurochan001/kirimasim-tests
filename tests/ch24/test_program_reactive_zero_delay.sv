/*
:name: test_program_reactive_zero_delay
:description: A program's initial procedure runs in the reactive region, and a #0 delay in it resumes there after the module's active processes of the time step have finished (IEEE 1800-2023 Sections 24.3.1 and 4.4.2.6)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3.1 4.4.2.6 4.4.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_reactive_zero_delay.expected
*/
// IEEE 1800-2023 §24.3.1: an initial procedure of a program runs in the
// Reactive region, and §4.4.2.6: a #0 delay in a program resumes there too.
// The module's initial procedure writes m in the Active region at 5, while
// the program reaches its #0 at 5. §4.4.1: the Reactive region comes after
// the Active, Inactive and NBA regions of the time step, so the program reads
// m after the write, whether or not its process was ready first. The program
// waits once more after its message, and the module's $finish at 6 ends the
// run.

`timescale 1ns/1ns

program p_reactive;
  initial begin
    #5;
    #0;
    $display("%0d: after #0 m=%0d", $time,
             test_program_reactive_zero_delay.m);
    #10 $display("%0d: program goes on", $time);
  end
endprogram

module test_program_reactive_zero_delay;
  int m = 0;

  p_reactive p();

  initial begin
    #5 m = 7;
    #1 $finish;
  end
endmodule

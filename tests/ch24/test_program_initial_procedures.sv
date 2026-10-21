/*
:name: test_program_initial_procedures
:description: Every initial procedure of a program runs at time 0 and they share the program's variables, and the final procedure runs when the simulation ends while an initial procedure is still waiting (IEEE 1800-2023 Sections 24.3 and 9.2.3)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3 9.2.1 9.2.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_initial_procedures.expected
*/
// IEEE 1800-2023 §24.3: a program may hold several initial procedures, which
// all start at time 0 and share the variables of the program. §9.2.1: the
// procedures run concurrently. The three procedures here read and write n at
// different times, so the order of the messages is fixed. §9.2.3: the final
// procedure runs when the simulation ends. §24.3: the simulation ends when
// every initial procedure of every program has ended, so the second initial
// procedure waits once more after 5, and the module's $finish at 10 ends the
// run and the final procedure prints there.

`timescale 1ns/1ns

program p_init;
  int n = 0;

  initial begin
    #1 $display("%0d: first reads n=%0d", $time, n);
    #3 n = 5;
    $display("%0d: first sets n=%0d", $time, n);
  end

  initial #2 n = 1;

  initial begin
    #5 $display("%0d: second reads n=%0d", $time, n);
    #20 $display("%0d: second goes on", $time);
  end

  final $display("%0d: final n=%0d", $time, n);
endprogram

module test_program_initial_procedures;
  p_init p();

  initial #10 $finish;
endmodule

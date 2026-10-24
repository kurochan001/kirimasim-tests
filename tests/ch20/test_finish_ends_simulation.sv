/*
:name: test_finish_ends_simulation
:description: $finish ends the whole simulation at once, so neither the rest of the calling procedure nor any other process runs after it; $stop and $finish are accepted with and without a diagnostic argument (IEEE 1800-2023 Section 20.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_finish_ends_simulation.expected
*/
// IEEE 1800-2023 §20.2: $finish makes the simulator exit and return control
// to the operating system, so no statement runs after it: not the rest of the
// procedure that calls it, not the always procedure that would print every 4
// ns forever, and not the procedure waiting for 30 ns. Syntax 20-1 lets $stop
// and $finish be called without an argument or with a parenthesized
// diagnostic argument of 0, 1 or 2; the branch that holds those calls never
// runs, so they only have to be accepted. The call that runs uses 0, which
// prints no diagnostic message (Table 20-1). The standard does not fix the
// exit code of $finish, so the test does not check it.
//
// Version 5.052 of Verilator still runs the rest of the procedure that
// calls $finish and prints "10: after $finish".

`timescale 1ns/1ns

module test_finish_ends_simulation;
  bit never = 0;
  int level = 2;
  int ticks = 0;

  always #4 begin
    ticks++;
    $display("%0d: tick %0d", $time, ticks);
  end

  initial begin
    if (never) begin
      $stop;
      $stop(0);
      $stop(1);
      $stop(level);
      $finish;
      $finish(1);
      $finish(level);
    end
    #10 $display("%0d: calling $finish", $time);
    $finish(0);
    $display("%0d: after $finish", $time);
  end

  initial #30 $display("%0d: later process", $time);
endmodule

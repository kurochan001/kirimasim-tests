/*
:name: test_vpi_stmt_callback_loops
:description: cbStmt callbacks on a for loop come once before its initialization and then before each increment, on a fork-join block once before its statements, and on delay and event controls when they are encountered, before the delay or the event (IEEE 1800-2023 Section 38.36.1.2)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1.2 38.36.1.1 38.36.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_stmt_callback_loops.c
:expected_stdout: @test_vpi_stmt_callback_loops.expected
*/
// IEEE 1800-2023 §38.36.1.2 (Table 38-6): a cbStmt callback on a for loop
// comes before any of its control expressions is evaluated, and then on every
// iteration before the increment; on a fork block, once before any of its
// statements executes; on a delay control or an event control, when it is
// encountered, before the delay passes or the event happens. §38.36.1.1: the
// callback gets the current time in the type requested. The loop runs its body
// three times, so its callbacks see i as 7 (before i = 0), then 0, 1 and 2.
// The fork starts at time 0, and both delay controls in it are encountered at
// time 0; the event control is encountered at time 2, when the fork has
// joined, and go is triggered at 5. The callbacks are placed at the start of
// the simulation, and the counts of the delay controls are printed at its end
// (38.36.3), as the two branches of the fork can run in either order.

`timescale 1ns/1ns

module test_vpi_stmt_callback_loops;
  int i = 7, n = 0;
  event go;

  initial begin
    for (i = 0; i < 3; i++)
      n = n + i;
    fork
      #1 n = n + 10;
      #2 n = n + 20;
    join
    @(go) n = n + 100;
    $display("design: n=%0d at %0t", n, $time);
  end

  initial #5 -> go;
endmodule

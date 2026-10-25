/*
:name: test_final_finish_inside_final_ends_at_once
:description: $finish called inside a final procedure ends the simulation at once, so the rest of that final procedure does not run, and the final procedure does not run a second time (IEEE 1800-2023 Section 9.2.3)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_final_finish_inside_final_ends_at_once.expected
*/
// IEEE 1800-2023 §9.2.3: a final procedure runs when the simulation ends by
// an explicit or implicit $finish. Calling $finish from within a final
// procedure ends the simulation immediately, and a final procedure can be
// triggered only once in a simulation.
//
// The simulation ends by $finish at time 5. The only final procedure counts
// its runs, prints the count, calls $finish and would then print a second
// line. The expected output has the count line once with count 1 and no
// second line: the $finish inside the final procedure neither lets the rest
// of it run nor starts the final procedures again.
//
// The 5.052 release of Verilator goes on with the rest of the final
// procedure after $finish and prints the second line.

`timescale 1ns/1ns
module test_final_finish_inside_final_ends_at_once;
  int runs = 0;

  initial #5 $finish;

  final begin
    runs++;
    $display("final at t=%0t, run %0d", $time, runs);
    $finish;
    $display("after $finish in final, run %0d", runs);
  end
endmodule

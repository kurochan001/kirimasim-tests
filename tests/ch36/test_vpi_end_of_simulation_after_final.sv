/*
:name: test_vpi_end_of_simulation_after_final
:description: When $finish ends the simulation, the final procedures run before the cbEndOfSimulation callback (IEEE 1800-2023 Section 36.9.2)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.9.2 9.2.3 38.36.3 20.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_end_of_simulation_after_final.c
:expected_stdout: @test_vpi_end_of_simulation_after_final.expected
*/
// IEEE 1800-2023 §36.9.2: an application can register a callback for the end
// of the simulation, cbEndOfSimulation (38.36.3). §9.2.3: the final procedures
// run when the simulation ends through $finish (20.2), before any PLI
// callback that reports the end of the simulation. So the line of the final
// procedure comes before the line of the callback, both at time 10.

`timescale 1ns/1ns

module test_vpi_end_of_simulation_after_final;
  initial #10 $finish;

  final $display("final procedure at %0d", $time);
endmodule

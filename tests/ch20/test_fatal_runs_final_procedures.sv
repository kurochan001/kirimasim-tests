/*
:name: test_fatal_runs_final_procedures
:description: The implicit $finish of $fatal ends the simulation like $finish does, so final procedures run before the run ends with an error code (IEEE 1800-2023 Section 20.10)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.10 9.2.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: nonzero
:expected_stdout: @test_fatal_runs_final_procedures.expected
*/
// IEEE 1800-2023 §20.10: calling $fatal results in an implicit call of
// $finish, and a final procedure runs when the simulation ends through an
// explicit or implicit $finish (9.2.3). The final procedure prints the value
// that the counter had when $fatal was called at time 3.

module test_fatal_runs_final_procedures;
  int ticks = 0;

  initial begin
    repeat (3) #1 ticks++;
    $fatal(1, "giving up");
  end

  initial #10 ticks = 100;

  final $display("final: ticks=%0d", ticks);
endmodule

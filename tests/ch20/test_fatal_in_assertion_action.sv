/*
:name: test_fatal_in_assertion_action
:description: $fatal in the fail action of an immediate assertion ends the run with an error code when the assertion fails, and the pass action of an earlier check runs normally (IEEE 1800-2023 Section 20.10)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.10 16.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: nonzero
:expected_stdout: @test_fatal_in_assertion_action.expected
*/
// IEEE 1800-2023 §16.3: an immediate assertion runs its pass statement when
// the expression is true and its else statement when it is false. Here the
// else statement is $fatal, which ends the run with an error code (20.10).
// The first check passes; the second fails at time 2.

`timescale 1ns/1ns

module test_fatal_in_assertion_action;
  int level = 1;

  initial begin
    #1 assert (level < 3) $display("t=%0d: level %0d is fine", $time, level);
       else $fatal(1, "level too high");
    level = 5;
    #1 assert (level < 3) $display("t=%0d: level %0d is fine", $time, level);
       else $fatal(1, "level too high");
    $display("not reached");
  end
endmodule

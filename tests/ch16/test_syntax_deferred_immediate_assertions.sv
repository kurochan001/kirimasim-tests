/*
:name: test_syntax_deferred_immediate_assertions
:description: assert, assume and cover with #0 and with final evaluate their expression and the by-value arguments of their action when the statement is reached, so a later assignment in the same time step changes neither the result nor the value the action prints (IEEE 1800-2023 Section 16.4, A.6.10)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3 16.4 A.6.10 A.6.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_deferred_immediate_assertions.expected
*/
// IEEE 1800-2023 A.6.10: a deferred immediate assertion is "assert #0 (
// expression ) action_block", "assert final ( expression ) action_block" and
// the same for assume, and cover takes a statement or null statement.
// §16.4: as with all immediate assertions, the expression of a deferred
// assertion is evaluated when the statement is processed; only the reporting
// and the action blocks are scheduled later in the time step (the Observed
// and Reactive regions for #0, the Postponed region for final). Arguments of
// the action passed by value are evaluated at the same instant as the
// expression.
//
// Each check is true when it is reached and false after the assignment that
// follows it in the same time step, so each action runs and prints the time
// and the value of a at the statement: 0, 6, 7, 9, and the two assume passes.
// An implementation that evaluated the expression or the arguments later would
// print "wrong", skip a cover or print a later value.
//
// Until 2026-11-09 this test expected the opposite reading, that a deferred
// assertion samples its expression in the Observed or Postponed region.

`timescale 1ns/1ns

module test_syntax_deferred_immediate_assertions;
  int a = 0;

  initial begin
    a = 0;
    assert #0 (a == 0) $display("%0t assert zero sees %0d", $time, a);
      else $display("wrong");
    a = 5;
    #1;

    a = 6;
    assert final (a == 6) $display("%0t assert final sees %0d", $time, a);
      else $display("wrong");
    a = 16;
    #1;

    a = 7;
    cover #0 (a == 7) $display("%0t cover zero sees %0d", $time, a);
    a = 8;
    #1;

    a = 9;
    cover final (a == 9) $display("%0t cover final sees %0d", $time, a);
    a = 19;
    #1;

    a = 11;
    assume #0 (a == 11) $display("%0t assume zero pass", $time);
      else $display("wrong");
    a = 12;
    #1;

    a = 13;
    assume final (a == 13) $display("%0t assume final pass", $time);
      else $display("wrong");
    a = 23;
    #1;

    $display("done");
  end
endmodule

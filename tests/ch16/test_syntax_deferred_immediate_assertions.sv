/*
:name: test_syntax_deferred_immediate_assertions
:description: assert, assume and cover with #0 check the value in the observed region of the time step, after the statements that follow them, and with final at the end of the time step, so a later assignment in the same step decides the action (IEEE 1800-2023 Section 16.4, A.6.10)
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
// §16.4: the deferred assertion is not evaluated when it is reached but in
// the observed region of the current time step for #0, and at the end of the
// time step for final, so an assignment after the statement changes the value
// the check sees.
//
// At 0 a is 0 when the assert #0 is reached and becomes 5 after it, so the
// check fails and its else action prints 5. At 1 the assert final sees a = 6
// at the end of the step and passes. At 2 the cover #0 sees 8 after the
// assignment and runs its statement, and at 3 the cover final sees 9 and does
// the same. At 4 the assume #0 sees 12 and at 5 the assume final sees 13, so
// both pass. Each action prints the time and the value it saw.

`timescale 1ns/1ns

module test_syntax_deferred_immediate_assertions;
  int a = 0;

  initial begin
    a = 0;
    assert #0 (a == 0) $display("wrong");
      else $display("%0t assert zero sees %0d", $time, a);
    a = 5;
    #1;

    a = 6;
    assert final (a == 6) $display("%0t assert final sees %0d", $time, a);
      else $display("wrong");
    #1;

    a = 7;
    cover #0 (a == 8) $display("%0t cover zero sees %0d", $time, a);
    a = 8;
    #1;

    a = 9;
    cover final (a == 9) $display("%0t cover final sees %0d", $time, a);
    #1;

    a = 11;
    assume #0 (a == 12) $display("%0t assume zero pass", $time);
      else $display("wrong");
    a = 12;
    #1;

    a = 13;
    assume final (a == 13) $display("%0t assume final pass", $time);
      else $display("wrong");
    #1;

    $display("done");
  end
endmodule

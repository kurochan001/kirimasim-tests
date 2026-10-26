/*
:name: test_deferred_immediate_syntax_placement
:description: a deferred immediate assertion uses #0 or final after assert, assume or cover, may stand outside procedural code as a module_common_item with always_comb semantics, delays its action block, and runs an observed report in the Reactive region and a final report in the Postponed region (IEEE 1800-2023 Sections 16.4, 16.4.1 and 16.4.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.4 16.4.1 16.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_deferred_immediate_syntax_placement.expected
*/
// IEEE 1800-2023 §16.4: a deferred immediate assertion writes #0 (observed) or
// final (final) after assert, assume or cover; its expression is evaluated
// when the statement is processed, but its action is delayed to a later
// region of the same time step. It may stand outside procedural code, where
// §16.4.3 treats it as if it were in an always_comb procedure. §16.4.1: an
// observed report matures in the Observed region and its action runs in the
// Reactive region, after every Active event of the time step; a final report
// matures and runs in the Postponed region, after the Reactive region. The
// print of the assignment in the initial block is an Active event, so it comes
// before the observed report, which comes before the final report of the same
// time step. Each change of a variable runs only the static assertion that
// depends on it. The subroutine prints nothing at time 0, where the implicit
// always_comb procedures of the four static assertions all run once and their
// reports would have no order that the standard fixes.

`timescale 1ns/1ns

module test_deferred_immediate_syntax_placement;
  logic a = 0, b = 0, c = 0, d = 0;

  task automatic note(string s);
    if ($time != 0) $display("%s", s);
  endtask

  s1: assert #0 (a)
    note($sformatf("t=%0t s1 observed pass", $time));
    else note($sformatf("t=%0t s1 observed fail", $time));

  s2: assert final (b)
    note($sformatf("t=%0t s2 final pass", $time));
    else note($sformatf("t=%0t s2 final fail", $time));

  s3: cover #0 (c)
    note($sformatf("t=%0t s3 cover covered", $time));

  s4: assume #0 (d)
    note($sformatf("t=%0t s4 assume pass", $time));
    else note($sformatf("t=%0t s4 assume fail", $time));

  s5: assert #0 (b)
    note($sformatf("t=%0t s5 observed pass", $time));
    else note($sformatf("t=%0t s5 observed fail", $time));

  initial begin
    #5 a = 1;
    $display("t=%0t active a=1", $time);
    #5 b = 1;
    $display("t=%0t active b=1", $time);
    #5 c = 1;
    $display("t=%0t active c=1", $time);
    #5 d = 1;
    $display("t=%0t active d=1", $time);
    #5 d = 0;
    $display("t=%0t active d=0", $time);
    #5 c = 0;
    $display("t=%0t active c=0", $time);
    #5 $finish;
  end
endmodule

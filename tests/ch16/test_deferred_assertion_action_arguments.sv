/*
:name: test_deferred_assertion_action_arguments
:description: a deferred assertion evaluates its expression and the by-value arguments of its action, function calls included, when it is executed, also for a report that is flushed later; ref and const ref arguments read the variable when the action runs, after the NBA region for an observed deferred assertion and after the Reactive region for a final one (IEEE 1800-2023 Section 16.4)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.4 16.4.1 16.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_deferred_assertion_action_arguments.expected
*/
// IEEE 1800-2023 §16.4: the expression of a deferred assertion is evaluated
// when the statement is executed; only its action is deferred. Arguments of
// the action that are passed by value, function calls included, are fully
// evaluated at that instant, while ref and const ref arguments use the
// variables when the subroutine runs: in the Reactive region for #0, where a
// ref argument can also be written, and in the Postponed region for final.
// §16.4.1: the call and those argument values are queued on the process.
// At 10 a_obs passes with x = 1 and x then becomes 2; r gets 5 in the NBA
// region before the action runs. At 20 a_fin passes with x = 2; r gets 6 in
// the NBA region and the action of a_bump, an observed deferred assertion,
// adds 100 to r through a ref argument in the Reactive region, before the
// action of a_fin runs in the Postponed region. At 30 the always procedure
// runs twice: the second run, after resuming at its event control, flushes
// the first report (§16.4.2), but probe() was called for both. Only the
// display lines of the actions and of the initial procedure are printed.

`timescale 1ns/1ns

module test_deferred_assertion_action_arguments;
  int x = 0, r = 0, calls = 0;
  logic trig = 0;

  function automatic int probe(int v);
    calls++;
    return v * 10 + calls;
  endfunction

  task automatic report(string tag, int by_value, const ref int by_cref, ref int by_ref);
    $display("t=%0t %s: by value %0d, const ref %0d, ref %0d", $time, tag, by_value, by_cref,
             by_ref);
  endtask

  task automatic bump(ref int v);
    v = v + 100;
  endtask

  always @(trig) begin
    a_cap: assert #0 (x == 99) else report("a_cap fail", probe(x), r, r);
  end

  initial begin
    #10;
    x = 1;
    a_obs: assert #0 (x == 1) report("a_obs pass", x, r, r); else report("a_obs fail", x, r, r);
    x = 2;
    r <= 5;
    $display("t=%0t after a_obs: x=%0d r=%0d", $time, x, r);
    #10;
    a_fin: assert final (x == 2) report("a_fin pass", x, r, r); else report("a_fin fail", x, r, r);
    a_bump: assert #0 (1'b1) bump(r);
    x = 3;
    r <= 6;
    $display("t=%0t after a_fin: x=%0d r=%0d", $time, x, r);
    #10;
    x = 4;
    trig = 1;
    #0;
    x = 5;
    trig = 0;
    #1 $display("t=%0t probe() calls: %0d", $time, calls);
  end
endmodule

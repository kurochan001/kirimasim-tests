/*
:name: test_scope_randomize_all_constraints
:description: Scope randomize with no arguments changes no variable and evaluates every constraint, returning 0 when a later constraint is false and 1 when all are true (IEEE 1800-2023 Section 18.12)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_scope_randomize_all_constraints.expected
*/
// IEEE 1800-2023 §18.12: when std::randomize is called with no argument it
// shall not change the value of any variable but shall check its constraints;
// all constraint expressions in the block shall be evaluated, and the call
// returns 0 if one or more of them evaluates to false and 1 otherwise.
// a is 5 and b is 7. A constraint that is true of the current values (a == 5)
// returns 1, and one that is false (a == 6) returns 0. A block whose first
// constraint is true and whose last constraint is false (a == 5; b == 7;
// a == 9) returns 0 only if the last one is evaluated, so a tool that stops at
// the first true constraint differs. A constraint that permits several values
// (a inside {[0:9]}) returns 1 in 100 calls and must leave a at 5 each time,
// because no argument is randomized.

module test_scope_randomize_all_constraints;
  int a = 5, b = 7;
  int ok_true, ok_false, ok_later_false, ok_inside, changed;

  initial begin
    ok_true = randomize() with { a == 5; };
    ok_false = randomize() with { a == 6; };
    ok_later_false = randomize() with { a == 5; b == 7; a == 9; };
    changed = 0;
    for (int i = 0; i < 100; i++) begin
      ok_inside = randomize() with { a inside {[0:9]}; };
      if (a != 5 || b != 7) changed++;
    end
    $display("true %0d, false %0d, later false %0d",
             ok_true, ok_false, ok_later_false);
    $display("inside %0d, variables changed %0d, a %0d b %0d",
             ok_inside, changed, a, b);
  end
endmodule

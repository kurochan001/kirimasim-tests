/*
:name: test_foreach_oob_constraints_need_guards
:description: Out-of-bounds constraints using loop, constant and state indices remain active without user guards, while explicit bounds predicates remove them (IEEE 1800-2023 Section 18.5.7.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.7.1 18.5.12 7.4.5 18.6.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_foreach_oob_constraints_need_guards.expected
*/
// 18.5.7.1 B020 permits loop, constant and state indices and forbids
// automatically eliminating constraints with invalid indices. In each of
// the three foreach bodies the unguarded constraint includes a[2] == 4 on
// a[0:1]. Constant and state indices repeat that same constraint at i=0,1.
// Under 7.4.5 B013/B019 a nonexistent 2-state element reads 0, so that
// comparison cannot hold, and randomize returns 0 (18.6.1 B005). The
// if predicates are guards; when guarded=0, !guarded makes every selected
// predicate TRUE, so 18.5.12 B012/B020 creates the consequent constraints.
// The invalid access is in the consequent, not in an error-sifted predicate.
// No false-guard removal exception applies to that unguarded call.
// The bounds predicates involve only state/loop/constant expressions;
// 18.5.7.1 B019 and 18.5.12 remove the invalid constraint when guarded.
// The remaining exact element constraints then give a = '{3,4} and return 1.
// No array value after a failed randomization, warning wording, or random
// distribution is observed. Each failure is paired with a guarded success.

class indexed_guard_model;
  rand bit [7:0] a[0:1];
  int form;
  int index = 2;
  bit guarded;

  constraint exact_values {
    foreach (a[i]) a[i] == 8'(i + 3);
  }

  constraint indexed_values {
    if (form == 0)
      foreach (a[i])
        if (!guarded || i + 1 < 2) a[i + 1] == 8'd4;
    if (form == 1)
      foreach (a[i])
        if (!guarded || 2 < 2) a[2] == 8'd4;
    if (form == 2)
      foreach (a[i])
        if (!guarded || index < 2) a[index] == 8'd4;
  }
endclass

module test_foreach_oob_constraints_need_guards;
  indexed_guard_model model;
  int unguarded_ok, guarded_ok;
  initial begin
    for (int form = 0; form < 3; form++) begin
      model = new;
      model.form = form;
      model.guarded = 0;
      unguarded_ok = model.randomize();
      model.guarded = 1;
      guarded_ok = model.randomize();
      $display("form=%0d unguarded=%0d guarded=%0d values=%0d,%0d",
               form, unguarded_ok, guarded_ok, model.a[0], model.a[1]);
    end
  end
endmodule

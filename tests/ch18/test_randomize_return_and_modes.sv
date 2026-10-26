/*
:name: test_randomize_return_and_modes
:description: randomize returns 1 or 0 for a satisfiable or an unsatisfiable problem, constraint_mode names any constraint of the hierarchy and without a name affects all of them, rand_mode returns 1 for an active and 0 for an inactive variable, and an argument list applies to one call only (IEEE 1800-2023 Sections 18.6.1, 18.8, 18.9 and 18.11)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.6.1 18.8 18.9 18.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randomize_return_and_modes.expected
*/
// IEEE 1800-2023 §18.6.1: randomize() returns 1 when every random variable and
// object gets a valid value and 0 otherwise. §18.9: a constraint of the base
// class is named through the derived object, and the setter without a name
// applies to all constraints. §18.8: rand_mode() without an argument returns
// 1 for active and 0 for inactive.
// §18.11: the arguments of randomize() name the random variables of that call
// only; q is not rand, so a later call without arguments leaves it alone, and

class rm_base;
  rand int a;
  constraint c_base { a > 0; }
endclass

class rm_obj extends rm_base;
  rand int b;
  int q;
  constraint c_der { b == a + 1; }
  constraint c_all { b < 1000; }
endclass

module test_randomize_return_and_modes;
  rm_obj o = new;
  int succ1, succ2;
  int base_get, der_get, off_base, off_der, on_base, on_der;
  int off_violations, on_violations;
  int a_get_on, a_get_off, a_kept;
  int q_ok, q_kept;
  int q_saved;

  initial begin
    succ1 = o.randomize();
    succ2 = o.randomize() with { a == -1; };
    $display("return: success %0d, failure %0d", succ1, succ2);
    base_get = o.c_base.constraint_mode();
    der_get = o.c_der.constraint_mode();
    o.constraint_mode(0);
    off_base = o.c_base.constraint_mode();
    off_der = o.c_der.constraint_mode();
    off_violations = 0;
    repeat (20) begin
      void'(o.randomize());
      if (o.b != o.a + 1) off_violations++;
    end
    o.c_base.constraint_mode(1);
    on_base = o.c_base.constraint_mode();
    on_der = o.c_der.constraint_mode();
    on_violations = 0;
    repeat (20) begin
      void'(o.randomize());
      if (o.a <= 0) on_violations++;
      if (o.b == o.a + 1) on_violations++;
    end
    $display("constraint_mode: base getter %0d, all off %0d %0d, base only %0d %0d",
             base_get, off_base, off_der, on_base, on_der);
    $display("all off: constraints violated %0d, base only: a<=0 or b tied %0d",
             off_violations > 0, on_violations);
    o.constraint_mode(1);
    a_get_on = o.a.rand_mode();
    o.a.rand_mode(0);
    a_get_off = o.a.rand_mode();
    o.a = 10;
    void'(o.randomize());
    a_kept = (o.a == 10);
    o.a.rand_mode(1);
    $display("rand_mode: a getter %0d %0d, a kept %0d",
             a_get_on, a_get_off, a_kept);
    o.q = 5;
    q_ok = o.randomize(q) with { q > 100; q < 200; };
    q_ok = q_ok && o.q > 100 && o.q < 200;
    q_saved = o.q;
    void'(o.randomize());
    q_kept = (o.q == q_saved);
    $display("temporary: q in range %0d, q kept %0d", q_ok, q_kept);
  end
endmodule

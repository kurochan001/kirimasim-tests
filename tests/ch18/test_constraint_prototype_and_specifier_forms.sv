/*
:name: test_constraint_prototype_and_specifier_forms
:description: Constraint prototypes of the implicit, extern and pure forms, their external blocks with class scope, a static constraint, and the initial, extends and final specifiers give the values their declarations say after randomize() (IEEE 1800-2023 Sections 18.5.1, 18.5.2, 18.5.10 and 18.5.11)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.1 18.5.2 18.5.10 18.5.11 A.1.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_prototype_and_specifier_forms.expected
*/
// IEEE 1800-2023 §18.5.1 with A.1.10: a constraint prototype is either the
// implicit form, just its name, or bare extern; its block may be declared
// outside the class with the class scope. §18.5.2: a pure constraint of an
// abstract class is implemented by a derived class. §18.5.10: a static
// constraint is declared with static in front of constraint, on both the
// prototype and the external block here. The initial, extends and final
// specifiers before the constraint name (A.1.10) say that a constraint is
// not an override, is an override, or may not be replaced (§18.5.2).
//
// cb_base declares c_init with both specifiers, the implicit prototype
// c_implicit, the extern prototype c_explicit and the static prototype
// c_stat; the three external blocks follow the class. cb_der replaces
// c_explicit with a constraint marked extends. cb_impl gives the pure
// constraint of cb_abs a block. The printed values are then 1, 3, 4, 5 for
// the base instance, 1, 3, 40, 5, 6 for the derived one (d comes from the
// replacement) and 7 for the pure one.

class cb_base;
  rand int a, c, d, e;

  constraint : initial : final c_init { a == 1; }
  constraint c_implicit;
  extern constraint c_explicit;
  extern static constraint c_stat;
endclass

constraint cb_base::c_implicit { c == 3; }
constraint cb_base::c_explicit { d == 4; }
static constraint cb_base::c_stat { e == 5; }

class cb_der extends cb_base;
  rand int f;

  constraint : extends c_explicit { d == 40; f == 6; }
endclass

virtual class cb_abs;
  rand int p;
  pure constraint c_need;
endclass

class cb_impl extends cb_abs;
  constraint c_need { p == 7; }
endclass

module test_constraint_prototype_and_specifier_forms;
  cb_base b;
  cb_der d;
  cb_abs p;
  cb_impl pi;
  int ok;

  initial begin
    b = new;
    ok = b.randomize();
    $display("base ok=%0d a=%0d c=%0d d=%0d e=%0d", ok, b.a, b.c, b.d, b.e);
    d = new;
    ok = d.randomize();
    $display("derived ok=%0d a=%0d c=%0d d=%0d e=%0d f=%0d", ok, d.a, d.c, d.d,
             d.e, d.f);
    pi = new;
    p = pi;
    ok = p.randomize();
    $display("pure ok=%0d p=%0d", ok, p.p);
  end
endmodule

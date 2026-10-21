/*
:name: test_constraint_prototype_pure_override
:description: An implicit constraint prototype without an external block is an empty constraint, a prototype in a derived class replaces the inherited constraint of its name, and a derived class implements a pure constraint with a constraint block or with a prototype and an external block (IEEE 1800-2023 Section 18.5.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.1 18.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_prototype_pure_override.expected
*/
// IEEE 1800-2023 §18.5.1: a constraint prototype in the implicit form that no
// external constraint block completes is an empty constraint, which has no
// effect (a tool may warn about it): c_open does not keep randomize() of
// cpo_base from succeeding. §18.5.2: a prototype in a derived class with the
// name of an inherited constraint replaces it, and its external block gives
// the new constraint, so x is 20 in cpo_derived, also through a handle of
// the base class. A pure constraint of an abstract class has to be given by
// each non-abstract derived class, either by a constraint block (cpo_block)
// or by a prototype completed outside the class (cpo_extern).

class cpo_base;
  rand bit [7:0] x;
  constraint c_fix { x == 8'd10; }
  constraint c_open;
endclass

class cpo_derived extends cpo_base;
  extern constraint c_fix;
endclass

constraint cpo_derived::c_fix { x == 8'd20; }

virtual class cpo_abstract;
  rand bit [7:0] y;
  pure constraint c_need;
endclass

class cpo_block extends cpo_abstract;
  constraint c_need { y == 8'd30; }
endclass

class cpo_extern extends cpo_abstract;
  constraint c_need;
endclass

constraint cpo_extern::c_need { y == 8'd40; }

module test_constraint_prototype_pure_override;
  cpo_base b;
  cpo_derived d;
  cpo_abstract a;
  cpo_block cb;
  cpo_extern ce;
  int ok;

  initial begin
    b = new;
    ok = b.randomize();
    $display("base with an empty prototype: ok=%0d x=%0d", ok, b.x);
    d = new;
    b = d;
    ok = b.randomize();
    $display("derived prototype replaces c_fix: ok=%0d x=%0d", ok, b.x);
    cb = new;
    a = cb;
    ok = a.randomize();
    $display("pure constraint given by a block: ok=%0d y=%0d", ok, a.y);
    ce = new;
    a = ce;
    ok = a.randomize();
    $display("pure constraint given by an external block: ok=%0d y=%0d", ok, a.y);
  end
endmodule

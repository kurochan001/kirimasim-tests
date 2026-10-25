/*
:name: test_constraint_inherit_add_and_pure_chain
:description: A derived class inherits the constraints of its base, replaces those of the same name and adds those of a new name; a pure constraint implemented by an abstract or concrete subclass, by a block or by a prototype with an external block, stays non-pure for further subclasses; an abstract subclass may make an inherited constraint pure again (IEEE 1800-2023 Section 18.5.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.2 18.5.1 8.21 18.6.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_inherit_add_and_pure_chain.expected
*/
// IEEE 1800-2023 §18.5.2: a derived class inherits every constraint of its
// base class; a constraint with the name of an inherited one replaces it,
// and a constraint with a new name is added to the inherited ones.
// cia_derived replaces c_a (a == 1 becomes a == 11), keeps c_b (b < 200)
// and adds c_c (b == 2 * a % 8, so b == 6). cia_wrong adds c_c with
// b == 250, which together with the inherited c_b has no solution:
// randomize() fails and b keeps its value (18.6.3).
// A constraint block or prototype of the name of an inherited pure
// constraint overrides it in any subclass, abstract or not, and is non-pure
// for that class and its descendants: the abstract classes cia_abs_blk
// (block) and cia_abs_ext (prototype completed by an external block, 18.5.1)
// implement c_p, and their concrete subclasses cia_leaf_blk and
// cia_leaf_ext need no c_p of their own. cia_conc_blk and cia_conc_ext are
// concrete classes that implement c_p directly. An abstract class may also
// replace an inherited constraint by a pure constraint of the same name:
// cia_reabs makes c_a of cia_base pure, and its subclass cia_reimpl gives
// c_a again (a == 21) while c_b is still inherited.
// Icarus Verilog 13.0 does not compile classes with constraints.

class cia_base;
  rand bit [7:0] a, b;
  constraint c_a { a == 8'd1; }
  constraint c_b { b < 8'd200; }
endclass

class cia_derived extends cia_base;
  constraint c_a { a == 8'd11; }
  constraint c_c { b == (2 * a) % 8; }
endclass

class cia_wrong extends cia_base;
  constraint c_c { b == 8'd250; }
endclass

virtual class cia_pure;
  rand bit [7:0] p;
  pure constraint c_p;
endclass

virtual class cia_abs_blk extends cia_pure;
  constraint c_p { p == 8'd31; }
endclass

virtual class cia_abs_ext extends cia_pure;
  constraint c_p;
endclass

constraint cia_abs_ext::c_p { p == 8'd32; }

class cia_leaf_blk extends cia_abs_blk;
endclass

class cia_leaf_ext extends cia_abs_ext;
endclass

class cia_conc_blk extends cia_pure;
  constraint c_p { p == 8'd33; }
endclass

class cia_conc_ext extends cia_pure;
  extern constraint c_p;
endclass

constraint cia_conc_ext::c_p { p == 8'd34; }

virtual class cia_reabs extends cia_base;
  pure constraint c_a;
endclass

class cia_reimpl extends cia_reabs;
  constraint c_a { a == 8'd21; }
endclass

module test_constraint_inherit_add_and_pure_chain;
  cia_base base_h;
  cia_derived d;
  cia_wrong w;
  cia_pure pure_h;
  cia_leaf_blk lb;
  cia_leaf_ext le;
  cia_conc_blk cb;
  cia_conc_ext ce;
  cia_reimpl ri;
  int ok;

  initial begin
    d = new;
    base_h = d;
    ok = base_h.randomize();
    $display("replace and add: ok=%0d a=%0d b=%0d", ok, base_h.a, base_h.b);
    w = new;
    w.b = 8'd5;
    ok = w.randomize();
    $display("added constraint against inherited c_b: ok=%0d b=%0d", ok, w.b);

    lb = new;
    pure_h = lb;
    ok = pure_h.randomize();
    $display("abstract subclass block, concrete leaf: ok=%0d p=%0d", ok, pure_h.p);
    le = new;
    pure_h = le;
    ok = pure_h.randomize();
    $display("abstract subclass external block, concrete leaf: ok=%0d p=%0d", ok, pure_h.p);
    cb = new;
    pure_h = cb;
    ok = pure_h.randomize();
    $display("concrete subclass block: ok=%0d p=%0d", ok, pure_h.p);
    ce = new;
    pure_h = ce;
    ok = pure_h.randomize();
    $display("concrete subclass external block: ok=%0d p=%0d", ok, pure_h.p);

    ri = new;
    base_h = ri;
    ok = base_h.randomize();
    $display("pure again, then implemented: ok=%0d a=%0d b<200=%0d", ok, base_h.a,
             base_h.b < 200);
  end
endmodule

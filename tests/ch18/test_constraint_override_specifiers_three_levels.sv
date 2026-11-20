/*
:name: test_constraint_override_specifiers_three_levels
:description: Over three levels of classes, a constraint declared :initial can still be replaced later with :extends, a replacement declared :extends :final is kept by the class below, new constraints declared :initial or :initial :final are added, and randomize() through a base class handle honors the constraints of the object (IEEE 1800-2023 Section 18.5.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.2 18.5
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_override_specifiers_three_levels.expected
*/
// IEEE 1800-2023 §18.5.2: a derived class inherits the constraints of its
// superclass; a constraint of the same name replaces the inherited one and
// another name adds a constraint. :initial says that a constraint is not an
// override, :extends that it is one, and :final that no further replacement
// is allowed; final may be combined with initial or extends. Only final
// forbids later replacements. randomize() is virtual, so it honors the
// constraints of the object, whatever the type of the handle. §18.5: the
// specifiers come after the keyword constraint.
//
// co_base_c has c_x :initial (x == 1) and c_y (y == 2). co_mid_c replaces c_y
// with :extends :final (y == 20) and adds c_z :initial (z == 3). co_leaf_c
// replaces c_x, declared :initial in co_base_c, with :extends (x == 100),
// keeps c_y of co_mid_c and adds c_w :initial :final (w == 4). Every
// constraint is an equality, so each randomize() has one solution.
// Icarus Verilog 13.0 does not support override specifiers and stops with a
// syntax error.

class co_base_c;
  rand int x, y;
  constraint :initial c_x { x == 1; }
  constraint c_y { y == 2; }
endclass

class co_mid_c extends co_base_c;
  rand int z;
  constraint :extends :final c_y { y == 20; }
  constraint :initial c_z { z == 3; }
endclass

class co_leaf_c extends co_mid_c;
  rand int w;
  constraint :extends c_x { x == 100; }
  constraint :initial :final c_w { w == 4; }
endclass

module test_constraint_override_specifiers_three_levels;
  co_base_c b, h;
  co_mid_c m;
  co_leaf_c l;
  int ok;

  initial begin
    b = new;
    m = new;
    l = new;
    ok = b.randomize();
    $display("base: ok=%0d x=%0d y=%0d", ok, b.x, b.y);
    ok = m.randomize();
    $display("mid: ok=%0d x=%0d y=%0d z=%0d", ok, m.x, m.y, m.z);
    ok = l.randomize();
    $display("leaf: ok=%0d x=%0d y=%0d z=%0d w=%0d", ok, l.x, l.y, l.z, l.w);
    l = new;
    h = l;
    ok = h.randomize();
    $display("leaf through a base handle: ok=%0d x=%0d y=%0d w=%0d", ok, h.x, h.y, l.w);
  end
endmodule

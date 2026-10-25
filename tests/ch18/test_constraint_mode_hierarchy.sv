/*
:name: test_constraint_mode_hierarchy
:description: constraint_mode() turns named constraint blocks of the whole class hierarchy on and off, alone or all of an object at once, and returns the state of one block (IEEE 1800-2023 Section 18.9)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.9 18.3 18.5 18.5.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_mode_hierarchy.expected
*/
// IEEE 1800-2023 §18.9: obj.name.constraint_mode(bit on_off) turns the
// constraint block called name on (1) or off (0), where name can be any
// constraint block in the class hierarchy (18.3, 18.5: the name of a block
// identifies it for constraint_mode); obj.constraint_mode(bit) without a name
// applies to all the constraints of the object; obj.name.constraint_mode()
// returns 1 for an active block and 0 for an inactive one, and only this
// getter needs the name. obj is any expression that yields the handle.
// cmh_derived inherits c_a, replaces c_b (b == 20 instead of 2), adds c_c,
// and has c_e, a prototype completed by an external block (18.5.1). Every
// block fixes one variable, so an inline constraint (18.7) with another
// value succeeds only when the block is off.
// c_a, declared in the base class, is turned off through the derived object,
// and so are c_c and c_e, one at a time. The state belongs to each object:
// turning c_b off in objs[1], an element of an array, leaves it on in
// objs[0], and a block of an object reached through a member handle
// (w.inner) can be switched too.
// Icarus Verilog 13.0 does not compile classes with constraints.

class cmh_base;
  rand bit [7:0] a, b;
  constraint c_a { a == 8'd1; }
  constraint c_b { b == 8'd2; }
endclass

class cmh_derived extends cmh_base;
  rand bit [7:0] c, e;
  constraint c_b { b == 8'd20; }
  constraint c_c { c == 8'd3; }
  constraint c_e;
endclass

constraint cmh_derived::c_e { e == 8'd4; }

class cmh_wrap;
  cmh_derived inner = new;
endclass

module test_constraint_mode_hierarchy;
  cmh_derived d;
  cmh_derived objs[2];
  cmh_wrap w;
  int ok;

  function automatic string modes(cmh_derived h);
    return $sformatf("%0d%0d%0d%0d", h.c_a.constraint_mode(), h.c_b.constraint_mode(),
                     h.c_c.constraint_mode(), h.c_e.constraint_mode());
  endfunction

  initial begin
    d = new;
    ok = d.randomize();
    $display("all on: ok=%0d a=%0d b=%0d c=%0d e=%0d modes=%s", ok, d.a, d.b, d.c, d.e, modes(d));

    d.c_a.constraint_mode(0);
    ok = d.randomize() with { a == 8'd9; };
    $display("inherited c_a off: ok=%0d a=%0d b=%0d modes=%s", ok, d.a, d.b, modes(d));

    d.c_c.constraint_mode(0);
    ok = d.randomize() with { c == 8'd7; };
    $display("c_c off: ok=%0d c=%0d modes=%s", ok, d.c, modes(d));

    d.c_e.constraint_mode(0);
    ok = d.randomize() with { e == 8'd8; };
    $display("external c_e off: ok=%0d e=%0d modes=%s", ok, d.e, modes(d));

    d.constraint_mode(1);
    ok = d.randomize();
    $display("all on again: ok=%0d a=%0d b=%0d c=%0d e=%0d modes=%s", ok, d.a, d.b, d.c, d.e,
             modes(d));

    d.constraint_mode(0);
    ok = d.randomize() with { a == 8'd5; b == 8'd6; c == 8'd7; e == 8'd8; };
    $display("all off: ok=%0d a=%0d b=%0d c=%0d e=%0d modes=%s", ok, d.a, d.b, d.c, d.e,
             modes(d));

    objs[0] = new;
    objs[1] = new;
    objs[1].c_b.constraint_mode(0);
    $display("objs: modes %s %s", modes(objs[0]), modes(objs[1]));
    ok = objs[1].randomize() with { b == 8'd50; };
    $display("objs[1] with b == 50: ok=%0d b=%0d", ok, objs[1].b);
    ok = objs[0].randomize() with { b == 8'd50; };
    $display("objs[0] with b == 50: ok=%0d", ok);

    w = new;
    w.inner.c_c.constraint_mode(0);
    ok = w.inner.randomize() with { c == 8'd70; };
    $display("w.inner c_c off: ok=%0d c=%0d modes=%s", ok, w.inner.c, modes(w.inner));
  end
endmodule

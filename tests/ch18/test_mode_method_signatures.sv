/*
:name: test_mode_method_signatures
:description: rand_mode() and constraint_mode() take a bit argument as setters, return int as getters, and can be called through any expression that yields the object handle (IEEE 1800-2023 Sections 18.8 and 18.9)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.8 18.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mode_method_signatures.expected
*/
// IEEE 1800-2023 §18.8, §18.9: the setters are declared
// function void object[.random_variable].rand_mode(bit on_off) and
// function void object[.constraint_identifier].constraint_mode(bit on_off),
// and the getters function int object.random_variable.rand_mode() and
// function int object.constraint_identifier.constraint_mode(); object is any
// expression that yields the object handle. So:
// - the argument is converted to the 1-bit type bit like any argument of a
//   function (13.5): 2 becomes 0, which turns the variable or the block off,
//   and 3 becomes 1, which turns it on; this also holds for the setters of
//   the whole object, o.rand_mode(2) and o.constraint_mode(2);
// - each getter is an int function, so its result has 32 bits ($bits, 20.6.2);
// - the handle can come from an element of an array of handles (objs[1]) or
//   from a member of another object (w.inner), and the setter called through
//   it changes only that object.
// Each line prints the modes of x, y (rand_mode) and c_x, c_y
// (constraint_mode) of the object named.
// Icarus Verilog 13.0 does not compile classes with constraints. Verilator
// 5.052 treats any nonzero argument as 1 and gives 0 for $bits of the
// constraint_mode() getter.

class mms_obj;
  rand bit [7:0] x, y;
  constraint c_x { x < 8'd100; }
  constraint c_y { y < 8'd100; }
endclass

class mms_wrap;
  mms_obj inner = new;
endclass

module test_mode_method_signatures;
  mms_obj o;
  mms_obj objs[2];
  mms_wrap w;

  function automatic string modes(mms_obj h);
    return $sformatf("x%0d y%0d c_x%0d c_y%0d", h.x.rand_mode(), h.y.rand_mode(),
                     h.c_x.constraint_mode(), h.c_y.constraint_mode());
  endfunction

  initial begin
    o = new;
    $display("getter bits: rand_mode %0d, constraint_mode %0d",
             $bits(o.x.rand_mode()), $bits(o.c_x.constraint_mode()));
    o.x.rand_mode(2);
    o.c_x.constraint_mode(2);
    $display("x.rand_mode(2), c_x.constraint_mode(2): %s", modes(o));
    o.x.rand_mode(3);
    o.c_x.constraint_mode(3);
    $display("x.rand_mode(3), c_x.constraint_mode(3): %s", modes(o));
    o.rand_mode(2);
    o.constraint_mode(2);
    $display("o.rand_mode(2), o.constraint_mode(2): %s", modes(o));
    o.rand_mode(1);
    o.constraint_mode(1);
    $display("o.rand_mode(1), o.constraint_mode(1): %s", modes(o));

    objs[0] = new;
    objs[1] = new;
    objs[1].y.rand_mode(0);
    objs[1].c_y.constraint_mode(0);
    $display("objs[0]: %s, objs[1]: %s", modes(objs[0]), modes(objs[1]));

    w = new;
    w.inner.x.rand_mode(0);
    w.inner.c_y.constraint_mode(0);
    $display("w.inner: %s, getters through w.inner: %0d %0d", modes(w.inner),
             w.inner.x.rand_mode(), w.inner.c_y.constraint_mode());
  end
endmodule

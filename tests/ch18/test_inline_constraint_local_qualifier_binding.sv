/*
:name: test_inline_constraint_local_qualifier_binding
:description: Inside the inline constraint block of randomize() with, local:: makes a name bind in the scope of the call, a function argument or a property of the calling class, instead of a property of the object being randomized that has the same name (IEEE 1800-2023 Section 18.7.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.7.1 18.7 A.8.4 A.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_inline_constraint_local_qualifier_binding.expected
*/
// IEEE 1800-2023 §18.7.1 and footnote 48 of A.10 (on class_qualifier,
// A.8.4): the local:: qualifier is used within an inline constraint block.
// There an unqualified name is looked up first in the class of the object
// being randomized; local:: skips that class and binds the name in the scope
// that contains the randomize() call.
//
// C has the random properties x and y. The function set_from has an
// argument named x: in c.randomize() with { x == local::x + 1; ... } the
// first x is c.x and local::x is the argument 5, so c.x = 6 and y == x * 2
// gives c.y = 12. The class D has its own property x = 40; in its method,
// c.randomize() with { x == local::x - 1; y == local::x + x; } gives
// c.x = 39 and c.y = 40 + 39 = 79, the unqualified x again being c.x.
// Each constraint set has one solution, so the results do not depend on
// the random generator.
//
// Icarus Verilog 13.0 does not support randomize() with.

class C;
  rand int x;
  rand int y;
endclass

class D;
  int x = 40;

  function int fill(C c);
    return c.randomize() with { x == local::x - 1; y == local::x + x; };
  endfunction
endclass

module test_inline_constraint_local_qualifier_binding;
  function automatic int set_from(C c, int x);
    return c.randomize() with { x == local::x + 1; y == x * 2; };
  endfunction

  initial begin
    C c;
    D d;
    int ok;
    c = new;
    d = new;
    ok = set_from(c, 5);
    $display("argument: ok=%0d c.x=%0d c.y=%0d", ok, c.x, c.y);
    ok = d.fill(c);
    $display("class property: ok=%0d c.x=%0d c.y=%0d d.x=%0d", ok, c.x, c.y, d.x);
  end
endmodule

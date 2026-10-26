/*
:name: test_class_handle_alias_and_polymorphism
:description: class handles refer to one shared object, compare by identity, dispatch virtually through an abstract base, and support a down cast
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 8.28
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_handle_alias_and_polymorphism.expected
*/
// IEEE 1800-2023 8.4: a class instance is referenced by object handles; two
// handles assigned the same object refer to that one object, so a write
// through b2 is visible through b1 and l, and == compares identity rather
// than contents. 8.28: classes provide inheritance, abstraction and dynamic
// casts: Base is an abstract class with a pure virtual method, the object is
// a Leaf, the base handles dispatch to Leaf's override, and $cast to Mid
// succeeds. A tool that copies the object on handle assignment prints
// alias=7, and one without virtual dispatch prints 9.

virtual class Base;
  int v;
  pure virtual function int f();
endclass

class Mid extends Base;
  virtual function int f();
    return v + 1;
  endfunction
endclass

class Leaf extends Mid;
  virtual function int f();
    return v + 2;
  endfunction
endclass

module test_class_handle_alias_and_polymorphism;
  initial begin
    Leaf l;
    Base b1, b2;
    Mid m;
    int ok;

    l = new;
    l.v = 7;
    b1 = l;
    b2 = b1;
    b2.v = 9;
    ok = $cast(m, b1);
    $display("alias=%0d same=%0d nonnull=%0d", l.v, (b1 == b2), (b1 != null));
    $display("dispatch=%0d %0d %0d", b1.f(), b2.f(), l.f());
    $display("cast=%0d", ok);
  end
endmodule

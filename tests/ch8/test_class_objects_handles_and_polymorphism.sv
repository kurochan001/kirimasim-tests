/*
:name: test_class_objects_handles_and_polymorphism
:description: class objects are created dynamically and reached through handles, an override dispatches through a base handle, and a structure variable differs from a class handle
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.2 8.4 8.28
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_objects_handles_and_polymorphism.expected
*/
// IEEE 1800-2023 8.2: class instances are created and destroyed dynamically and
// are referenced through object handles. 8.4: a class instance is referenced
// by an object handle, not by a chandle or a pointer. 8.28: classes support
// inheritance, abstraction and dynamic casts under the class rules; a
// structure variable occupies storage, whereas a class variable is a handle
// whose object is created by new. The test creates two objects, assigns a
// derived object to a base handle, observes virtual dispatch through that
// handle and the sharing of one object by two handles, and contrasts that with
// two independent structure variables.

class base;
  int v;

  function new(int x = 0);
    v = x;
  endfunction

  virtual function int get();
    return v;
  endfunction
endclass

class derived extends base;
  int w;

  function new(int x, int y);
    super.new(x);
    w = y;
  endfunction

  virtual function int get();
    return v + w;
  endfunction
endclass

module test_class_objects_handles_and_polymorphism;
  base b;
  derived d;
  base h;

  initial begin
    b = new(3);
    d = new(4, 5);
    h = d;
    $display("b=%0d d=%0d h=%0d", b.get(), d.get(), h.get());
    $display("not_null=%0d same_object=%0d", b != null, h == d);
    d.w = 50;
    $display("shared=%0d %0d", d.get(), h.get());
    begin : struct_scope
      automatic struct {int x;} s1, s2;
      s1.x = 1;
      s2 = s1;
      s2.x = 2;
      $display("struct=%0d %0d", s1.x, s2.x);
    end
  end
endmodule

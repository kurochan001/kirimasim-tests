/*
:name: test_shallow_copy_operand_handle_forms
:description: The operand of a shallow copy new is an expression that evaluates to an object handle, such as a class variable, a function call, an array element or a property of another object; each copy is a new object with the properties of the one the handle refers to, without a constructor call (IEEE 1800-2023 Section 8.12)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.12 A.2.4 A.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_shallow_copy_operand_handle_forms.expected
*/
// IEEE 1800-2023 §8.12 and footnote 23 of A.10 (on class_new, A.2.4): in
// the shallow copy form new expression, the expression evaluates to an
// object handle. The copy allocates a new object of the class, without
// calling its constructor, copies every property into it, handles included
// (so an object that a property refers to is shared, not copied), and its
// handle is the value assigned.
//
// The operands used here: the class variable a, the call pick(1) of a
// function that returns a handle, the array element arr[0], the property
// h.p of another object, and h.p again in the initializer of the automatic
// variable c5, which runs when its block is entered (6.21). Each copy has
// the id of the object its operand refers to (1, 2, 1, 3, 3), the
// constructor ran only for the 3 objects made with new(...), each copy is a
// different object from the original, and it shares the Node object of the
// original: writing c2.n.v changes arr[1].n.v, while writing c1.tag leaves
// a.tag unchanged.
//
// Icarus Verilog 13.0 reports a syntax error for new pick(1), a function
// call as the operand of a shallow copy.

class Node;
  int v;
endclass

class Pkt;
  static int built = 0;
  int id;
  string tag;
  Node n;

  function new(int i);
    id = i;
    tag = "orig";
    n = new;
    n.v = 10 * i;
    built++;
  endfunction
endclass

class Holder;
  Pkt p;
endclass

module test_shallow_copy_operand_handle_forms;
  Pkt arr[2];

  function automatic Pkt pick(int k);
    return arr[k];
  endfunction

  initial begin
    Pkt a, c1, c2, c3, c4;
    Holder h;
    h = new;
    arr[0] = new(1);
    arr[1] = new(2);
    h.p = new(3);
    a = arr[0];
    c1 = new a;
    c2 = new pick(1);
    c3 = new arr[0];
    c4 = new h.p;
    begin
      automatic Pkt c5 = new h.p;
      $display("ids: c1=%0d c2=%0d c3=%0d c4=%0d c5=%0d", c1.id, c2.id, c3.id, c4.id, c5.id);
      $display("new objects: %0d %0d %0d %0d %0d", c1 != a, c2 != arr[1], c3 != arr[0],
               c4 != h.p, c5 != h.p);
    end
    $display("constructor calls: %0d", Pkt::built);
    $display("shared Node: %0d %0d", c1.n == a.n, c2.n == arr[1].n);
    c1.tag = "copy";
    c2.n.v = 99;
    $display("a.tag=%s c1.tag=%s arr[1].n.v=%0d", a.tag, c1.tag, arr[1].n.v);
  end
endmodule

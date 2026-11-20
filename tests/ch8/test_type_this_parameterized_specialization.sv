/*
:name: test_type_this_parameterized_specialization
:description: In a parameterized class, type(this) is the specialization that encloses it: a method with that return type gives a handle of the specialization, a property of that type links objects of the same specialization, each specialization counts its own objects, and type(this) matches its own specialization but not another one (IEEE 1800-2023 Sections 8.11, 6.23, 8.25)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.11 6.23 8.25
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_this_parameterized_specialization.expected
*/
// IEEE 1800-2023 §6.23: type(this) stands for the type of the enclosing
// class, and a variable declared with a type reference needs var in front;
// type references can be compared with == and are equal only when the types
// match. §8.11: this may appear as type(this) in a class. §8.25: the
// enclosing type of a parameterized class is a specialization, each
// specialization has its own static variables, and all matching
// specializations of a class declared in a package are one type.
//
// In stack #(T), push() returns type(this) and makes its new object with a
// local variable of that type, so push() of a stack #(byte) object gives a
// handle that can be assigned to a variable of type stack #(byte), and the
// property below holds another object of the same specialization. The value
// 200 given to the constructor of stack #(byte) becomes the byte -56; the
// same value stays 200 in stack #(int). made counts 2 objects of
// stack #(byte) and 1 of stack #(int). is_byte_stack() compares type(this)
// with stack #(byte): 1 in that specialization and 0 in stack #(int).
// Icarus Verilog 13.0 does not support parameterized classes in this form
// and stops with a syntax error on the class header.

package test_type_this_ps_pkg;
  class stack #(type T = int);
    static int made;
    T value;
    var type(this) below;

    function new(T v);
      value = v;
      made++;
    endfunction

    function type(this) push(T v);
      var type(this) s = new(v);
      s.below = this;
      return s;
    endfunction

    function int depth();
      if (below == null) return 1;
      return 1 + below.depth();
    endfunction

    function bit is_byte_stack();
      return type(this) == type(stack #(byte));
    endfunction
  endclass
endpackage

module test_type_this_parameterized_specialization;
  import test_type_this_ps_pkg::*;
  typedef stack #(byte) byte_stack;
  typedef stack #(int) int_stack;

  byte_stack b1, b2;
  int_stack i1;

  initial begin
    b1 = new(200);
    b2 = b1.push(7);
    i1 = new(200);
    $display("byte: %0d %0d depth=%0d made=%0d", b2.below.value, b2.value, b2.depth(),
             byte_stack::made);
    $display("int: %0d depth=%0d made=%0d", i1.value, i1.depth(), int_stack::made);
    $display("is_byte_stack: %0d %0d", b2.is_byte_stack(), i1.is_byte_stack());
  end
endmodule

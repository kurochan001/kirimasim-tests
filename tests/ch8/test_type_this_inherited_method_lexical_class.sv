/*
:name: test_type_this_inherited_method_lexical_class
:description: type(this) names the class in whose body it is written, so in a method that a subclass inherits it is still the base class: the comparison with the base class holds there, and a handle returned as type(this) by the inherited method has the base type, which decides the call of a nonvirtual method, while a virtual method still runs the override (IEEE 1800-2023 Sections 8.11, 6.23)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.11 6.23 8.20
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_this_inherited_method_lexical_class.expected
*/
// IEEE 1800-2023 §6.23: type(this) is the type of the enclosing class, the
// class whose declaration contains it, and two type references are equal only
// when their types match. §8.11: this may appear as type(this) in a class.
// A method that a subclass inherits is still declared in the base class, so
// there type(this) is the base class, also when the method is called on an
// object of the subclass.
//
// lex_derived inherits is_base() and me() from lex_base and adds is_derived(),
// also_base() and me_derived(). Called on a lex_derived object, is_base()
// gives 1; in the subclass, type(this) matches lex_derived (1) and not
// lex_base (0). §8.20: a nonvirtual method is chosen by the type of the
// handle, a virtual one by the object. me() returns type(this) of lex_base,
// so kind() through it is the base version, and me_derived() returns a
// lex_derived handle, so kind() through it is the subclass version; vkind()
// is virtual and gives the subclass version through either handle.
// Icarus Verilog 13.0 does not support type(this) and stops with a syntax
// error.

class lex_base;
  function bit is_base();
    return type(this) == type(lex_base);
  endfunction
  function type(this) me();
    return this;
  endfunction
  function string kind();
    return "base kind";
  endfunction
  virtual function string vkind();
    return "base vkind";
  endfunction
endclass

class lex_derived extends lex_base;
  function bit is_derived();
    return type(this) == type(lex_derived);
  endfunction
  function bit also_base();
    return type(this) == type(lex_base);
  endfunction
  function type(this) me_derived();
    return this;
  endfunction
  function string kind();
    return "derived kind";
  endfunction
  virtual function string vkind();
    return "derived vkind";
  endfunction
endclass

module test_type_this_inherited_method_lexical_class;
  lex_derived d;

  initial begin
    d = new;
    $display("inherited is_base: %0d", d.is_base());
    $display("in the subclass: derived %0d, base %0d", d.is_derived(), d.also_base());
    $display("me().kind: %s", d.me().kind());
    $display("me_derived().kind: %s", d.me_derived().kind());
    $display("me().vkind: %s", d.me().vkind());
  end
endmodule

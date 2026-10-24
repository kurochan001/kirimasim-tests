/*
:name: test_abstract_class_chain_and_handle_array
:description: a concrete class can be extended into an abstract (virtual) class that adds pure virtual methods and overrides a method as pure, abstract classes can extend abstract classes, and variables and arrays of an abstract class type hold objects of derived classes (IEEE 1800-2023 Sections 8.21, 8.22)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.21 8.22
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_abstract_class_chain_and_handle_array.expected
*/
// IEEE 1800-2023 §8.21: a class declared with the keyword virtual is abstract:
// it can declare pure virtual methods and its objects are not constructed
// directly, only through the constructor chain of a non-abstract subclass.
// Any class may be extended into an abstract class, which may add pure
// virtual methods or override methods with pure ones; abstract classes may be
// extended into further abstract classes. §8.22: an abstract class can still
// be the type of a variable or of the elements of an array, which then hold
// objects of derived classes, whose methods are called through them.
// plain_c is concrete; shape_c extends it as an abstract class, adds sides
// and overrides base_val as pure; poly_c is still abstract and implements
// only base_val; tri_c and sq_c are complete. shape_c's constructor sets built
// when the objects are made, and the array arr of shape_c and the handles of
// plain_c and poly_c call the implementations of the objects.
// Icarus Verilog 13.0 does not support pure virtual methods.

class plain_c;
  virtual function int base_val();
    return 1;
  endfunction
endclass

virtual class shape_c extends plain_c;
  int built;
  function new();
    built = 1;
  endfunction
  pure virtual function int sides();
  pure virtual function int base_val();
endclass

virtual class poly_c extends shape_c;
  virtual function int base_val();
    return 10;
  endfunction
endclass

class tri_c extends poly_c;
  virtual function int sides();
    return 3;
  endfunction
endclass

class sq_c extends poly_c;
  virtual function int sides();
    return 4;
  endfunction
  virtual function int base_val();
    return 20;
  endfunction
endclass

module test_abstract_class_chain_and_handle_array;
  shape_c arr [2];
  poly_c p;
  plain_c pl;
  plain_c alone;
  tri_c t;
  sq_c s;

  initial begin
    t = new;
    s = new;
    arr[0] = t;
    arr[1] = s;
    p = s;
    pl = t;
    alone = new;
    $display("array: sides=%0d,%0d base_val=%0d,%0d built=%0d,%0d", arr[0].sides(),
             arr[1].sides(), arr[0].base_val(), arr[1].base_val(), arr[0].built, arr[1].built);
    $display("poly_c handle: sides=%0d base_val=%0d", p.sides(), p.base_val());
    $display("plain_c handles: tri object=%0d plain object=%0d", pl.base_val(), alone.base_val());
  end
endmodule

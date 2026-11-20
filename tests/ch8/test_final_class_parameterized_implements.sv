/*
:name: test_final_class_parameterized_implements
:description: A class declared :final can have parameters, extend an abstract class and implement an interface class in a package; its specializations keep their own static variables, and its objects are used through handles of the abstract base and of the interface class (IEEE 1800-2023 Sections 8.13, 8.25, 8.26)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.13 8.3 8.25 8.26 8.21
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_final_class_parameterized_implements.expected
*/
// IEEE 1800-2023 §8.3: the final specifier comes after the keyword class and
// before the class name and its parameter port list, and the header can also
// have extends and implements. §8.13: :final only says that no class may
// extend this one. So a final class can still be parameterized (§8.25), each
// specialization having its own static variables, extend an abstract class
// whose pure virtual method it implements (§8.21), and implement an interface
// class (§8.26).
//
// poly_c #(N) is final, extends base_c and implements shape_ic. Two objects of
// poly_c #(4) and one of poly_c #() (N = 3) are made, so the counters are 2
// and 1. sides() through the shape_ic handle of a poly_c #(4) object gives 4,
// and greet() of base_c, called through a base_c handle of the poly_c #()
// object and directly on a poly_c #(4) object, calls the overriding name().
// Icarus Verilog 13.0 does not parse interface classes and stops with a
// syntax error.

package final_combo_pkg;
  interface class shape_ic;
    pure virtual function int sides();
  endclass

  virtual class base_c;
    pure virtual function string name();
    function string greet();
      return {"I am ", name()};
    endfunction
  endclass

  class :final poly_c #(int N = 3) extends base_c implements shape_ic;
    static int made;
    function new();
      made++;
    endfunction
    virtual function int sides();
      return N;
    endfunction
    virtual function string name();
      return $sformatf("poly%0d", N);
    endfunction
  endclass
endpackage

module test_final_class_parameterized_implements;
  import final_combo_pkg::*;
  poly_c #(4) sq1, sq2;
  poly_c #() tri3;
  shape_ic s;
  base_c b;

  initial begin
    sq1 = new;
    sq2 = new;
    tri3 = new;
    s = sq1;
    b = tri3;
    $display("sides: %0d %0d", s.sides(), tri3.sides());
    $display("%s, %s", b.greet(), sq2.greet());
    $display("made: %0d %0d", poly_c#(4)::made, poly_c#()::made);
  end
endmodule

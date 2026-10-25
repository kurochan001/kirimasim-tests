/*
:name: test_interface_class_inherited_virtual_implementation
:description: a class that implements an interface class can take the implementation of an interface method from a virtual method it inherits from its base class, without declaring the method itself (IEEE 1800-2023 Sections 8.26 and 8.26.2)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.26 8.26.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_class_inherited_virtual_implementation.expected
*/
// IEEE 1800-2023 §8.26: when a class implements an interface class, the
// implementations of the interface methods may be provided by inherited
// virtual method implementations (also 8.26.2, where a class extends a
// class and implements interface classes at the same time).
//
// base_c has the virtual method area returning 10 and knows nothing of
// shape_if. sq_c extends base_c and implements shape_if without declaring
// area; the inherited area is the implementation. A shape_if handle to an
// sq_c object calls it. A second class, rect_c, overrides the inherited
// method, and its own version is called.
//
// The 5.052 release of Verilator rejects sq_c as missing an implementation
// of area; Icarus Verilog 13.0 does not support interface classes.

module test_interface_class_inherited_virtual_implementation;
  interface class shape_if;
    pure virtual function int area();
  endclass

  class base_c;
    virtual function int area();
      return 10;
    endfunction
  endclass

  class sq_c extends base_c implements shape_if;
  endclass

  class rect_c extends base_c implements shape_if;
    virtual function int area();
      return 12;
    endfunction
  endclass

  shape_if h;
  sq_c s;
  rect_c r;

  initial begin
    s = new;
    h = s;
    $display("sq_c through shape_if (inherited area): %0d", h.area());
    r = new;
    h = r;
    $display("rect_c through shape_if (own area): %0d", h.area());
  end
endmodule

/*
:name: test_interface_class_implemented_by_subclass
:description: a subclass of a class that implements an interface class implements it too, without naming it, so an interface class handle can refer to the subclass object by assignment or by $cast (IEEE 1800-2023 Section 8.26)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.26 8.26.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_class_implemented_by_subclass.expected
*/
// IEEE 1800-2023 §8.26: a subclass implicitly implements all of the
// interface classes implemented by its superclass, with the same
// requirements and capabilities as if it named them. So a variable of the
// interface class type can hold a handle of the subclass (8.26.5), and a
// $cast to the interface class type succeeds for a subclass object held in
// a superclass handle; calls go to the object's own method.
//
// impl_c implements shape_if; sub_c extends impl_c without naming shape_if
// and overrides area; sub2_c extends impl_c and overrides nothing.
// Icarus Verilog 13.0 does not support interface classes.

module test_interface_class_implemented_by_subclass;
  interface class shape_if;
    pure virtual function int area();
  endclass

  class impl_c implements shape_if;
    virtual function int area();
      return 20;
    endfunction
  endclass

  class sub_c extends impl_c;
    virtual function int area();
      return 30;
    endfunction
  endclass

  class sub2_c extends impl_c;
  endclass

  shape_if h, h2;
  impl_c ib;
  sub_c d;
  sub2_c d2;
  int ok;

  initial begin
    d = new;
    h = d;
    $display("sub_c through shape_if: %0d", h.area());
    d2 = new;
    ib = d2;
    ok = $cast(h2, ib);
    $display("$cast of an impl_c handle to a sub2_c to shape_if: %0d, area %0d", ok, h2.area());
  end
endmodule

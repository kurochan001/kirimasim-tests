/*
:name: test_interface_class_type_access
:description: Parameters and typedefs of an interface class are inherited by an interface class that extends it but not by a class that implements it, which reaches them with the class scope resolution operator (IEEE 1800-2023 Section 8.26.3)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.26.3 8.26.2 8.23
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_class_type_access.expected
*/
// IEEE 1800-2023 §8.26.3: the parameters and typedefs of an interface class
// are inherited by interface classes that extend it, not by classes that
// implement it, and they are static, so the class scope resolution operator
// reaches them (8.23). solid_if uses pair_t of shape_if without a prefix; the
// class box implements solid_if and has to name the type as solid_if#(int)::
// pair_t. SIDES is read through both interface classes.

module test_interface_class_type_access;
  interface class shape_if #(type T = int);
    typedef T pair_t [2];
    parameter int SIDES = 4;
    pure virtual function pair_t corner();
  endclass

  interface class solid_if #(type T = int) extends shape_if #(T);
    pure virtual function pair_t extent();
  endclass

  class box implements solid_if #(int);
    virtual function solid_if#(int)::pair_t corner();
      return '{1, 2};
    endfunction
    virtual function solid_if#(int)::pair_t extent();
      return '{30, 40};
    endfunction
  endclass

  box b;
  solid_if #(int) s;
  solid_if#(int)::pair_t c;
  shape_if#(int)::pair_t e;

  initial begin
    b = new();
    s = b;
    c = s.corner();
    e = s.extent();
    $display("corner %0d,%0d extent %0d,%0d", c[0], c[1], e[0], e[1]);
    $display("sides %0d %0d", shape_if#(int)::SIDES, solid_if#(int)::SIDES);
  end
endmodule

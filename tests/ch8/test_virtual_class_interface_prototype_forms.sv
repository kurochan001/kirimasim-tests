/*
:name: test_virtual_class_interface_prototype_forms
:description: a virtual class that implements an interface class meets each interface method by defining a virtual method, by redeclaring the pure prototype, by inheriting a virtual method or by inheriting a pure virtual prototype, and its non-abstract subclasses supply the bodies it left out (IEEE 1800-2023 Sections 8.26 and 8.26.2)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.26 8.26.2 8.26.7 8.21
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_class_interface_prototype_forms.expected
*/
// IEEE 1800-2023 §8.26: a virtual (abstract) class that implements an
// interface class shall define or inherit, for each pure virtual method of
// the interface class, either a pure virtual prototype or a virtual method
// implementation. §8.26.2: because virtual classes are abstract, they need
// not define all the methods of the interface classes they implement
// (8.26.7).
//
// poly_c implements shape_if and meets its four methods in the four ways:
// sides is defined in poly_c, area is redeclared there as pure, name is the
// virtual method inherited from named_c, and perimeter is the pure prototype
// inherited from the virtual class outline_c. The non-abstract subclasses
// square_c and tri_c define area and perimeter; square_c also overrides
// name, tri_c keeps the inherited one. Calls through shape_if and poly_c
// handles reach these methods: square_c(5) has area 25, 4 sides, perimeter
// 20 and the name "square"; tri_c has area 6, 3 sides, perimeter 12 and the
// inherited name "named".
//
// The 5.052 release of Verilator rejects poly_c, saying that the perimeter
// inherited from outline_c needs conflict resolution, and with perimeter
// redeclared in poly_c its generated C++ code does not compile (name is found
// in two base classes); Icarus Verilog 13.0 does not support interface
// classes.

module test_virtual_class_interface_prototype_forms;
  interface class shape_if;
    pure virtual function int area();
    pure virtual function int sides();
    pure virtual function string name();
    pure virtual function int perimeter();
  endclass

  class named_c;
    virtual function string name();
      return "named";
    endfunction
  endclass

  virtual class outline_c extends named_c;
    pure virtual function int perimeter();
  endclass

  virtual class poly_c extends outline_c implements shape_if;
    int n;
    virtual function int sides();
      return n;
    endfunction
    pure virtual function int area();
  endclass

  class square_c extends poly_c;
    int len;
    function new(int len);
      this.len = len;
      n = 4;
    endfunction
    virtual function int area();
      return len * len;
    endfunction
    virtual function int perimeter();
      return 4 * len;
    endfunction
    virtual function string name();
      return "square";
    endfunction
  endclass

  class tri_c extends poly_c;
    function new();
      n = 3;
    endfunction
    virtual function int area();
      return 6;
    endfunction
    virtual function int perimeter();
      return 12;
    endfunction
  endclass

  square_c sq;
  tri_c tr;
  shape_if s[2];
  poly_c p;

  initial begin
    sq = new(5);
    tr = new();
    s[0] = sq;
    s[1] = tr;
    foreach (s[i])
      $display("shape_if %0d: area=%0d sides=%0d perimeter=%0d name=%s", i, s[i].area(),
               s[i].sides(), s[i].perimeter(), s[i].name());
    p = tr;
    $display("poly_c: area=%0d sides=%0d perimeter=%0d name=%s", p.area(), p.sides(),
             p.perimeter(), p.name());
  end
endmodule

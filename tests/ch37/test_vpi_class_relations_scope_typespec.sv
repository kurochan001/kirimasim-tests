/*
:name: test_vpi_class_relations_scope_typespec
:description: Class definitions are iterated from the NULL design root, each gives its instance and its automatic property, and its static and automatic variables, methods, events, constraints in declaration order and parameters, each leading back with the class definition relation; class typedef typespecs lead back too, a derived class extends the base class with its constructor-chaining arguments, and a built-in class has no class definition (IEEE 1800-2023 Sections 37.31, 37.32)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.31 37.32 8.6 8.13 8.17 18.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_class_relations_scope_typespec.c
:expected_stdout: @test_vpi_class_relations_scope_typespec.expected
*/
// IEEE 1800-2023 §37.31: the NULL design root iterates class definitions,
// and a class definition gives its instance (37.31 diagram). Its
// variables, methods, events and event arrays include static and automatic
// declarations but not an implicit built-in method (detail 1); its
// constraints are the normal ones in declaration order, with an extern
// constraint at its prototype position (detail 4); its parameters are those
// of the parameter port list and of the class body (detail 7). Every variable,
// method, event, constraint and parameter leads back with the class definition
// relation, and a class typedef typespec does too (37.31 diagram, 37.32
// detail 1). A class definition's vpiAutomatic is the default lifetime of
// the variables of its declared methods, which is automatic (§8.6). §37.32:
// a derived class's vpiExtends gives the base class typespec, whose
// vpiArgument iteration gives the constructor-chaining arguments (37.31
// detail 6), and that base typespec leads back to its class definition with
// vpiClassDefn (37.32 diagram). vpiClassDefn returns NULL for a built-in
// class (37.32 detail 13). Lists other than constraints are sorted.

module test_vpi_class_relations_scope_typespec;
  class cr_base #(int W = 2);
    static int s;
    int a;
    event ev;
    event eva [0:1];
    parameter int P = 3;
    constraint c_base { a > 0; }
    static function int sf();
      return s;
    endfunction
    function int af();
      return a;
    endfunction
    function new (int seed);
      s = seed;
    endfunction
  endclass

  class cr_der extends cr_base;
    int b;
    typedef logic [3:0] nib_t;
    typedef logic [7:0] byte_t;
    constraint c_mid { b > 1; }
    extern constraint c_late;
    function new (int v);
      super.new(v);
      b = v;
    endfunction
  endclass

  constraint cr_der::c_late { b < 9; }

  class cr_plain;
    int q;
  endclass

  process proc;

  initial #1 $vt_classes;
endmodule

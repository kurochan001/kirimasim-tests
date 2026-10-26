/*
:name: test_vpi_class_specialization_types
:description: A class specialization from a variable or typedef gives its class definition, vpiClassType, vpiAutomatic and non-empty name, and its parameter assignment value; a derived specialization extends the base specialization with the chained parameters and inherits the base constraints; a class-definition iteration yields only specializations that lead back; a lexical class typespec gives an explicit or default parameter RHS and supports none of the class content iterations, while an elaborated specialization iterates each virtual interface array element with vpiVirtualInterfaceVar and one array variable with vpiVariables (IEEE 1800-2023 Sections 37.32, 37.12)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.32 37.12 37.31 8.13 8.25
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_class_specialization_types.c
:expected_stdout: @test_vpi_class_specialization_types.expected
*/
// IEEE 1800-2023 §37.32: a class typespec whose parameters are all resolved is
// a specialization; a variable's class typespec and a typespec used through a
// typedef are specializations (detail 1), with a valid tool-dependent name
// (detail 4). vpiClassType is vpiUserDefinedClass for a user class and
// vpiProcessClass for process (§37.32 diagram, Annex K), and vpiAutomatic is
// the default lifetime of the variables of its methods, which is automatic
// (§8.6). vpiParamAssign gives each parameter assignment; the RHS of a lexical
// class typespec is the explicit parameter expression or the declared default,
// and of a specialization it is an object with the correct value (detail 3).
// The vpiClassTypespec iteration of a class definition gives its
// specializations, each leading back with vpiClassDefn (detail 10). A lexical
// class typespec supports none of vpiVariables, vpiMethods, vpiConstraint,
// vpiNamedEvent, vpiNamedEventArray, vpiTypedef and vpiInternalScope
// (detail 2). A typespec obtained from a class definition through vpiTypedef,
// from a class-item declaration, or from the extends object is lexical
// (detail 1), and vpiVirtualInterfaceVar is not supported there (37.12
// detail 7). A specialization's vpiExtends gives the base specialization
// (detail 9), and the base constraints come from traversing it (37.31
// detail 4). The vpiVirtualInterfaceVar iteration of a specialization returns
// each element of a virtual interface array separately, while vpiVariables
// returns the declaration as one vpiArrayVar (37.12 detail 7, 37.32
// detail 11).

interface sps_bus;
  logic req;
endinterface

module test_vpi_class_specialization_types;
  class sp_base #(int W = 4);
    int x;
    virtual sps_bus vifs [0:1];
    constraint cb { x > 0; }
  endclass

  class sp_der #(int W = 8) extends sp_base#(W);
    typedef sp_base#(5) sp_nested_t;
    sp_base m;
    int y;
    constraint cd { y > 0; }
  endclass

  typedef sp_base#(2) sp_alias_t;

  sp_base#(8) b8;
  sp_alias_t a2;
  sp_der#(3) d3;
  sp_der#(4) d4;
  process proc;

  initial #1 $vt_spec;
endmodule

/*
:name: test_vpi_variable_scope_relations
:description: vpiVariables iterates the variables declared directly in a module, an interface instance, a named block and a generate block, without nets, named events, parameters or the variables of inner scopes, and a variable leads with vpiInstance to its instance and with vpiScope to the scope that declares it (IEEE 1800-2023 Section 37.17)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.17 37.10 37.12 37.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_variable_scope_relations.c
:expected_stdout: @test_vpi_variable_scope_relations.expected
*/
// IEEE 1800-2023 §37.17: a module, an instance and a scope iterate their
// variables with vpiVariables (the untagged access type of the "variables"
// group, 37.3), and a variable has one-to-one relations to its instance and
// its scope. The module declares the variables mem, n, r, re and s; the net w,
// the named event e and the parameter P are not variables, and bv, bl and gv
// belong to the inner scopes blk and g, so vpi_iterate(vpiVariables, module)
// gives the five variables only; the array mem is one variable. The interface
// instance bus (an instance, 37.10) gives ii and il, the named block blk (a
// scope, 37.12) bl and bv, and the generate block g gv. vpiInstance of bus.ii
// is bus and that of blk.bv the module; vpiScope of blk.bv is blk, of g.gv g,
// of bus.il bus and of n the module. Lists are sorted by name.

interface test_vpi_variable_scope_relations_if;
  logic [3:0] il;
  int ii;
  wire iw;
endinterface

module test_vpi_variable_scope_relations;
  parameter P = 1;
  logic r;
  int n;
  real re;
  string s;
  logic [7:0] mem [0:1];
  wire w;
  event e;

  test_vpi_variable_scope_relations_if bus();

  if (P == 1) begin : g
    int gv;
  end

  initial begin : blk
    int bv;
    logic [1:0] bl;
    #1 $vt_vars;
  end
endmodule

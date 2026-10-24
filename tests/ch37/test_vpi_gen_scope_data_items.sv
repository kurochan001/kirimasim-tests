/*
:name: test_vpi_gen_scope_data_items
:description: A gen scope iterates its nets, net arrays, logic variables, variable arrays (also with vpiMemory), all its variables, named events, named event arrays and typedefs, and each of these objects, its parameters and its typespecs lead back to the gen scope with vpiGenScope, while objects of the module outside it give NULL (IEEE 1800-2023 Section 37.85)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.85 27.5 6.20.4 37.16 37.17 37.20
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_gen_scope_data_items.c
:expected_stdout: @test_vpi_gen_scope_data_items.expected
*/
// IEEE 1800-2023 §37.85: a gen scope leads to the items declared in it, with
// one-to-many relations named by their object types (37.3): vpiNet,
// vpiArrayNet, vpiLogicVar, vpiArrayVar, vpiVariables, vpiNamedEvent,
// vpiNamedEventArray, and vpiMemory, which gives array variables (37.20
// detail 1). vpiTypedef gives the typespecs that have an explicit typedef in
// it (detail 5). Each of these objects, and each parameter and typespec of
// the gen scope, leads back to it with the one-to-one relation vpiGenScope.
// A parameter in a generate block is a local parameter (detail 4, 6.20.4).
//
// The conditional generate block g (27.5) declares one item of each kind;
// av is its only variable array, a one-dimensional array of 4-bit logic, so
// both vpiArrayVar and vpiMemory give it alone; anon_s is a variable of a
// struct type without a typedef, so it is among the variables but no typedef
// is returned for its type. The module itself declares mod_t, top_w and top_v
// outside g. From a start-of-simulation callback the application prints the
// names each iteration of g returns, sorted, then the full name of vpiGenScope
// of each item (found by name, or for the typespec by the iteration) and NULL
// for the objects outside g.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiArrayNet, vpiVariables and other types
// used here; a run with Verilator 5.052 returns all the variables, events
// and arrays of g for vpiLogicVar, nothing for the other iterations, and NULL
// for vpiGenScope.

module test_vpi_gen_scope_data_items;
  typedef int mod_t;
  wire top_w;
  logic top_v;

  if (1) begin : g
    typedef logic [2:0] tri_t;
    parameter int P = 3;
    wire w;
    wire na [0:1];
    logic lv;
    logic [3:0] av [0:2];
    int iv;
    struct packed { logic a; } anon_s;
    event ev;
    event eva [0:1];
  end
endmodule

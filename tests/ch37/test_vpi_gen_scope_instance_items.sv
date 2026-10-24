/*
:name: test_vpi_gen_scope_instance_items
:description: A gen scope iterates its processes, continuous assignments, module, program and interface instances and instance arrays, primitives and primitive arrays, defparams, nested gen scope arrays, assertions, alias statements and clocking blocks, and each of these, and a task declared in it, leads back to the gen scope with vpiGenScope (IEEE 1800-2023 Section 37.85)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.85 27.5 23.10.1 37.10 37.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_gen_scope_instance_items.c
:expected_stdout: @test_vpi_gen_scope_instance_items.expected
*/
// IEEE 1800-2023 §37.85: a gen scope leads to the items instantiated or
// declared in it, with one-to-many relations named by their object types
// (37.3): vpiProcess, vpiContAssign, vpiModule, vpiModuleArray, vpiPrimitive,
// vpiPrimitiveArray, vpiDefParam, vpiGenScopeArray, vpiProgram,
// vpiProgramArray, vpiAssertion, vpiInterface, vpiInterfaceArray,
// vpiAliasStmt and vpiClockingBlock. Each of these objects, and each scope in
// the gen scope such as a task, leads back to it with vpiGenScope.
//
// The conditional generate blocks g1 and g2 (27.5) hold one item of each kind:
// the single instances in g1 and the instance arrays in g2, so that no
// iteration depends on whether the elements of an array are also listed with
// the single instances. The defparam in g1 changes a parameter of the module
// instance in g1 (23.10.1). The module itself instantiates u_top outside the
// gen scopes. From a start-of-simulation callback the application prints the
// names each iteration returns, sorted (a process by its kind, a continuous
// assignment and an alias by their sides, a defparam by the full name of the
// parameter it sets), then the full name of vpiGenScope of each item, found
// by name or, for the unnamed ones, by the iteration; u_top gives NULL.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiProcess, vpiContAssign and other types
// used here; a run with Verilator 5.052 lists the interface instance among
// the modules, finds none of the other items and gives NULL for vpiGenScope.

interface gsi_ifc;
  logic s;
endinterface

program gsi_prog;
endprogram

module gsi_leaf #(parameter int W = 1) ();
endmodule

module test_vpi_gen_scope_instance_items;
  logic clk, a, b, c;
  wire y1, y2, s1, s2;
  wire [1:0] y3;

  gsi_leaf u_top ();

  if (1) begin : g1
    initial a = 1'b0;
    assign y1 = b;
    gsi_leaf u_mod ();
    and p_and (y2, a, b);
    defparam u_mod.W = 4;
    for (genvar k = 0; k < 2; k++) begin : inner
    end
    gsi_prog u_prg ();
    gsi_ifc u_ifc ();
    alias s1 = s2;
    clocking cb @(posedge clk);
    endclocking
    a_chk: assert property (@(posedge clk) a |-> b);
    task gt;
    endtask
  end

  if (1) begin : g2
    gsi_leaf u_arr [0:1] ();
    or p_arr [1:0] (y3, {a, b}, {c, c});
    gsi_prog u_prga [0:1] ();
    gsi_ifc u_ifca [0:1] ();
  end
endmodule

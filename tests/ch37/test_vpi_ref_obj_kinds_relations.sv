/*
:name: test_vpi_ref_obj_kinds_relations
:description: Ref objs come from the low connections of interface and ref ports, the high connection of an interface port, io declarations, and expressions that use ref ports, interface signals and ref task arguments; they give their name, full name, actual, parent, instance, task, typespec, definition name and ports, and vpiGeneric is TRUE for a generic interface, FALSE for a typed one and vpiUndefined otherwise (IEEE 1800-2023 Section 37.15)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.15 37.14 37.13 23.2.2 13.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_ref_obj_kinds_relations.c
:expected_stdout: @test_vpi_ref_obj_kinds_relations.expected
*/
// IEEE 1800-2023 §37.15: a ref obj is a declared reference to an actual
// object: the low connection of a ref port and its subelements, an interface
// or modport passed through a port and the signals reached through it, and a
// ref task argument (detail 1). It is reached by walking port connections, by
// an expression that uses it, or from an io decl (detail 2). vpiActual gives
// the object it is bound to (detail 3), vpiParent the ref obj of which it is a
// subelement (detail 4). vpiGeneric is TRUE for a generic interface, FALSE for
// a typed interface and vpiUndefined for every other ref obj (detail 5);
// vpiDefName of an interface ref obj is the interface name (detail 6); its
// typespec is NULL unless its actual is a net, variable or part-select
// (detail 7). A ref obj has relations to its instance or task func and,
// through vpiPorts, to the ports whose low connection it is; vpiHighConn of an
// interface port gives a ref obj too (37.14). Each $vt_ref call passes a use
// of a ref obj; $vt_ports walks the ports and io decls of m.

interface rok_if;
  logic v;
endinterface

module rok_leaf (rok_if c);
endmodule

module rok_mid (rok_if s, interface g, ref logic [2:0] r);
  int cnt = 5;

  rok_leaf c1 (s);

  task automatic tr(ref int t);
    $vt_ref("t", t);
  endtask

  initial begin
    #1 $vt_ref("r", r);
    $vt_ref("r[1]", r[1]);
    $vt_ref("s.v", s.v);
    tr(cnt);
    $vt_ports;
  end
endmodule

module test_vpi_ref_obj_kinds_relations;
  rok_if i0();
  logic [2:0] a = 3'b010;

  rok_mid m (.s(i0), .g(i0), .r(a));
endmodule

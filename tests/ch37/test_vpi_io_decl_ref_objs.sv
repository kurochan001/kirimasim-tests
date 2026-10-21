/*
:name: test_vpi_io_decl_ref_objs
:description: the io declarations of a module give the range of a vector port as written, vpiRef for a ref port, and a ref obj as the expression of ref, interface, modport and generic interface ports, whose actual, definition name, generic flag and typespec follow the kind of port; a ref obj that selects a bit of a ref port has that port's ref obj as parent and the bit of the actual as actual (IEEE 1800-2023 Section 37.13)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.13 37.15 37.63 37.64 23.2.2.2 23.2.2.3 23.3.3.4 25.3.3 25.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_io_decl_ref_objs.c
:expected_stdout: @test_vpi_io_decl_ref_objs.expected
*/
// IEEE 1800-2023 §37.13: vpi_iterate(vpiIODecl) over the instance u gives its
// io declarations. The input a has its direction and size, its range is that of
// its typespec, 7:4 (detail 4), and its expression is the port's net
// (23.2.2.3). The ref port link has vpiDirection vpiRef (detail 1); for it, and
// for the interface port b, the modport port d and the generic interface port g
// (23.3.3.4, 25.3.3, 25.5), vpiExpr is a ref obj (detail 2). The direction of
// the last three is undefined (detail 3) and not printed. §37.15: vpiActual of
// a ref obj is the object it is bound to: the variable tap, the interface
// instance bi or its modport dev (detail 3); vpiDefName is the interface or
// modport name (detail 6); vpiGeneric is 1 only for the generic interface port
// (detail 5); vpiTypespec is NULL as the actual is not a net, variable or part
// select (detail 7). The target of link[4] = 1'b1 in u, reached through the
// process, its statement and vpiLhs (37.63, 37.64), is a ref obj whose
// vpiParent is the ref obj link and whose vpiActual is the bit tap[4]
// (detail 4).
// The io declarations are printed sorted by name.

`timescale 1ns/1ns

interface test_vpi_io_decl_ref_objs_bus;
  logic req = 1'b0, gnt;
  modport dev (input req, output gnt);
endinterface

module test_vpi_io_decl_ref_objs_m (
  input logic [7:4] a,
  ref logic [5:2] link,
  test_vpi_io_decl_ref_objs_bus b,
  test_vpi_io_decl_ref_objs_bus.dev d,
  interface g
);
  initial link[4] = 1'b1;
endmodule

module test_vpi_io_decl_ref_objs;
  logic [3:0] nib = 4'h9;
  logic [5:2] tap = 4'b0001;

  test_vpi_io_decl_ref_objs_bus bi ();
  test_vpi_io_decl_ref_objs_m u (.a(nib), .link(tap), .b(bi), .d(bi.dev), .g(bi));

  initial #1 $vt_io;
endmodule

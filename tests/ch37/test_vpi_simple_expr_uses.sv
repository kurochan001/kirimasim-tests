/*
:name: test_vpi_simple_expr_uses
:description: Nets, variables, parameters and specparams are simple expressions that iterate their uses with vpiUse; the uses of a vector include those of its bit-selects and part-selects, and the uses of a bit-select are those of that bit, of the whole vector and of part-selects that contain it; a bit-select has a name and full name with its index (IEEE 1800-2023 Section 37.58)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.58 37.16 37.47 37.35 6.20.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_simple_expr_uses.c
:expected_stdout: @test_vpi_simple_expr_uses.expected
*/
// IEEE 1800-2023 §37.58: nets, variables, parameters and specparams are in the
// simple expression group, which iterates the uses of an object with vpiUse:
// primitive terminals, continuous assignments and the other kinds listed
// there. For a vector, the uses are those of the vector and of its
// part-selects and bit-selects (detail 1); for a bit-select, those of that
// bit, of the whole vector and of the part-selects that contain the bit
// (detail 2). A bit-select has vpiName and vpiFullName, which, as for the
// indexed objects of 37.16 detail 34, include its index. §6.20.5: a specparam
// can appear in an expression of the module body.
//
// The vector net v is used whole by wa, through v[1] by wb, through v[2:1] by
// wc2, through v[3] by wd and through v[0] by input terminal 1 of the gate g1;
// the vector variable r through r[0] by terminal 2 of g1 and through r[2] by
// wf; P by wg and SP by wsp. Nothing else uses them. From a start-of-
// simulation callback the application prints the uses of v, r, P and SP and of
// the bit-select v[1] taken from the right-hand side of the assignment to wb,
// with that bit-select's names: a continuous assignment by its left-hand side,
// a primitive terminal by its vpiTermIndex. The uses are sorted.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiUse and other constants used here, and
// with --vpi the C++ model that Verilator 5.052 generates does not compile, as
// it refers to a member for the specparam SP that it lacks.

module test_vpi_simple_expr_uses;
  parameter int P = 2;
  specparam SP = 3;
  wire [3:0] v;
  logic [3:0] r;
  wire wa, wb, wd, we, wf, wg, wsp;
  wire [1:0] wc2;

  assign wa = v;
  assign wb = v[1];
  assign wc2 = v[2:1];
  assign wd = v[3];
  and g1 (we, v[0], r[0]);
  assign wf = r[2];
  assign wg = P[1];
  assign wsp = SP > 1;
endmodule

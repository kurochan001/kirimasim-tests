/*
:name: test_vpi_systf_argument_expressions
:description: Selects and expressions in the arguments of a user-defined system task are vpiBitSelect, vpiPartSelect and vpiOperation objects, and an omitted argument is a vpiOperation with vpiOpType vpiNullOp (IEEE 1800-2023 Section 37.42)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.42 36.4 37.59 38.15
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_argument_expressions.c
:expected_stdout: @test_vpi_systf_argument_expressions.expected
*/
// IEEE 1800-2023 §37.42: an argument of a system task call is an expression
// of the object model: a bit-select is a vpiBitSelect, a part-select a
// vpiPartSelect, and an expression with an operator a vpiOperation whose
// vpiOpType names the operator (37.59). An omitted argument (detail 8) is a
// vpiOperation whose vpiOpType is vpiNullOp. The application prints the kind
// of each argument and, except for the omitted one, its value (38.15). The
// call has an omitted argument between r + 1 and r[0].

`timescale 1ns/1ns

module test_vpi_systf_argument_expressions;
  reg [7:0] r = 8'h5a;

  initial #1 $vt_kinds(r[1], r[6:3], r + 1, , r[0]);
endmodule

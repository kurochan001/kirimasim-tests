/*
:name: test_vpi_instance_array_kinds
:description: a two-dimensional module array gives its ranges from the leftmost, the bounds of its leftmost range, an element by multiple index, its connections as a list operation and its parameter assignment; elements of interface, program and gate arrays give their index, and instances outside an array give none; a gate array gives its delay (IEEE 1800-2023 Section 37.11)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.11 37.5 37.6 37.9 37.35 37.28 37.3.4 23.3.3.5 23.6 28.3.6 24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_instance_array_kinds.c
:expected_stdout: @test_vpi_instance_array_kinds.expected
*/
// IEEE 1800-2023 §37.11: arrays of instances (23.3.3.5, 28.3.6) are module,
// interface, program and primitive array objects, which a module iterates
// (37.5, 37.10). vpi_iterate(vpiRange) of the module array u [1:0][2:4] gives
// its ranges from the leftmost one, while vpiLeftRange and vpiRightRange give
// the bounds of the leftmost range (detail 2); vpi_handle_by_multi_index
// (38.20) gives the element whose hierarchical name is u[0][3] (23.6); vpiExpr
// gives an operation of type vpiListOp (detail 1); vpiParamAssign gives the
// parameter assignment of the array, whose vpiLhs is the overridden parameter W
// and whose vpiRhs is 3, and vpiConnByName is true as it is made by name (37.28
// diagram and detail 4). An interface (37.6 detail 1), a program (37.9 detail
// 1) and a primitive (37.35 detail 4) that is an element of an array gives its
// index through vpiIndex, and NULL when it is not in an array. vpiDelay of a
// gate array gives its delay expression, the constant 3 (37.3.4). The programs
// end at 5, which ends the simulation (24.3).

`timescale 1ns/1ns

interface test_vpi_instance_array_kinds_bus;
  logic v = 1'b0;
endinterface

program test_vpi_instance_array_kinds_prog;
  initial #5;
endprogram

module test_vpi_instance_array_kinds_leaf #(parameter int W = 1) (input wire a, input wire b);
  wire [W-1:0] both = {W{a & b}};
endmodule

module test_vpi_instance_array_kinds;
  wire a = 1'b1;
  wire b = 1'b0;
  wire [1:0] ga;
  wire gor;

  test_vpi_instance_array_kinds_leaf #(.W(3)) u [1:0][2:4] (a, b);
  test_vpi_instance_array_kinds_bus ifs [0:1] ();
  test_vpi_instance_array_kinds_bus one ();
  test_vpi_instance_array_kinds_prog pa [2:3] ();
  test_vpi_instance_array_kinds_prog po ();
  and #3 g [1:0] (ga, a, b);
  or go (gor, a, b);

  initial #2 $vt_arrays;
endmodule

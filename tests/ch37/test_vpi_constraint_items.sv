/*
:name: test_vpi_constraint_items
:description: The vpiConstraint iteration returns constraints in declaration order, with an extern one at its prototype, vpiAutomatic and vpiAccessType reflect static and extern, and constraint items and expressions come in source order, with a skipped foreach index as a null operation (IEEE 1800-2023 Section 37.34)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.34 37.38 37.31 18.5.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_constraint_items.c
:expected_stdout: @test_vpi_constraint_items.expected
*/
// IEEE 1800-2023 §37.34: vpiConstraint returns the constraints of a class in
// declaration order, an extern constraint at the place of its prototype;
// vpiAutomatic is 0 only for a constraint declared static (18.5.10), and
// vpiAccessType is vpiExternAcc for one defined outside the class.
// vpiConstraintItem returns the items of a constraint in order. §37.38: a
// foreach constraint gives the array with vpiVariables and its index variables
// with vpiLoopVars, a skipped index as an operation of type vpiNullOp;
// vpiConstraintExpr returns the expressions of an if-else in order, and
// vpiElseConst those of the else branch. The class definition is found from the
// module (37.31).

`timescale 1ns/1ns

module test_vpi_constraint_items;
  class packet;
    rand int a, b;
    rand int arr [3];
    rand int grid [2][3];
    constraint c_first { a < 10; b > a; }
    extern constraint c_ext;
    constraint c_second {
      foreach (arr[i]) arr[i] > 0;
      if (a > 5) b < 20; else b < 30;
    }
    static constraint c_static { a >= 0; }
    constraint c_skip { foreach (grid[, j]) grid[1][j] < 9; }
  endclass

  constraint packet::c_ext { b != 3; }

  initial #1 $vt_constraints;
endmodule

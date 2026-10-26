/*
:name: test_vpi_constraint_iteration
:description: Constraint iteration gives the normal constraints in syntactic order, an extern constraint at its prototype, the inherited constraints through the base typespec, and all constraints of the design from the NULL root, without the inline constraint of a randomize with call (IEEE 1800-2023 Sections 37.31, 37.32, 37.34)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.31 37.32 37.34 18.5 18.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_constraint_iteration.c
:expected_stdout: @test_vpi_constraint_iteration.expected
*/
// IEEE 1800-2023 §37.31 detail 3 and 4: the vpiConstraint iteration of a
// class definition returns the normal constraints and not inline ones, in
// syntactic declaration order, with an extern constraint at the position of
// its prototype, and the inherited constraints are reached through the
// extends relation. §37.32 detail 7 and 8: the same holds for a class
// typespec. §37.34: the NULL design root iterates the constraints of the
// design (37.34 diagram), and the iteration returns them in syntactic order
// (detail 4). The design has two constraints in the base class, one normal and
// one extern constraint in the derived class, and one inline constraint in a
// randomize with call, which the iterations do not return.

`timescale 1ns/1ns

module test_vpi_constraint_iteration;
  class ci_base;
    rand int a;
    constraint c_base { a > 0; }
    constraint c_base2 { a < 10; }
  endclass

  class ci_der extends ci_base;
    rand int b;
    constraint c_mid { b > 1; }
    extern constraint c_late;
  endclass

  constraint ci_der::c_late { b < 9; }

  ci_der d;

  initial begin
    d = new;
    if (!d.randomize() with { b > 2; })
      $display("randomize failed");
    #1 $vt_con;
  end
endmodule

/*
:name: test_vpi_constraint_expr_contents
:description: the condition and the expressions of an if-else, if, implication and foreach constraint come with their contents in source order, the else branch through vpiElseConst; a constraint gives its full name and vpiAccessType vpiExternAcc only when defined outside the class, and each dist item leads back to its distribution (IEEE 1800-2023 Sections 37.38 and 37.34)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.38 37.34 37.31 37.10 18.5.1 18.5.3 18.5.5 18.5.6 18.5.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_constraint_expr_contents.c
:expected_stdout: @test_vpi_constraint_expr_contents.expected
*/
// IEEE 1800-2023 §37.38: a constr if else gives its condition with
// vpiCondition, the expressions of its first branch with vpiConstraintExpr
// and those of its else branch with vpiElseConst (18.5.6); a constr if and an
// implication (18.5.5) give their condition and their expressions, and a
// constr foreach (18.5.7.1) its expressions; each vpiConstraintExpr iteration
// returns them in the order in which they are written (detail 3). Every
// branch here holds two expressions with different operators and constants,
// and the application prints each one as its operator with its operands,
// names for variables and values for constants (for the selects arr[i] only
// the operator and the constant). §37.34: vpiAccessType of a constraint is
// vpiExternAcc for c_ext, defined outside the class (18.5.1), and zero for
// the others (detail 3); vpiFullName of a constraint of the class defn pkt is
// the class name followed by :: and its name, since :: follows a class defn
// in a full name (37.10 detail 5). A dist constraint is a distribution, and
// vpiDistribution of each of its dist items is that distribution again
// (18.5.3). The class definition is found from the module (37.31). No object
// is randomized.

module test_vpi_constraint_expr_contents;
  class pkt;
    rand int a, b, c;
    rand int arr [3];
    constraint c_ifelse { if (a > 5) { b < 20; c > 1; } else { b < 30; c > 2; } }
    constraint c_if { if (c == 3) { a != 4; b != 5; } }
    constraint c_impl { (b == 7) -> { a < 3; c < 4; } }
    constraint c_each { foreach (arr[i]) { arr[i] > 0; arr[i] < 9; } }
    constraint c_dist { a dist { 1 := 1, 2 := 2 }; b dist { [3:4] :/ 1 }; }
    extern constraint c_ext;
  endclass

  constraint pkt::c_ext { c != 0; }

  initial #1 $vt_constraints;
endmodule

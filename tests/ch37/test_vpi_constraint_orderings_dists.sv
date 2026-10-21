/*
:name: test_vpi_constraint_orderings_dists
:description: a solve-before constraint is a constraint ordering with its before and after variables, a dist constraint a distribution whose items give their value or range, their := or :/ type and their weight, an implication and an if constraint give their condition and expressions in order, a soft constraint and a disable soft constraint are told apart, and the constraints of a class object lead back to it and show whether constraint_mode() has turned them off (IEEE 1800-2023 Sections 37.34 and 37.38)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.34 37.38 37.31 37.33 37.22 18.5.3 18.5.5 18.5.6 18.5.9 18.5.13.2 18.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_constraint_orderings_dists.c
:expected_stdout: @test_vpi_constraint_orderings_dists.expected
*/
// IEEE 1800-2023 §37.34: a constraint iterates its items in order (detail 5);
// solve a before b, c (§18.5.9) is a constraint ordering whose vpiSolveBefore
// iteration gives a, the variable solved first and written before "before",
// and vpiSolveAfter b and c; a dist constraint (§18.5.3) is a distribution
// whose vpiExpr is a and whose dist items give vpiDistType (vpiEqualDist for
// :=, vpiDivDist for :/), the value or the range (§37.22) as vpiValueRange
// and the weight as vpiWeight. A constraint of a class object leads back to
// it with vpiParent, and vpiIsConstraintEnabled, its active flag, is FALSE
// once constraint_mode(0) has turned it off (§18.9). The class definition and
// the object give the constraints in declaration order (detail 4; §37.31,
// §37.33). §37.38: an implication (§18.5.5) and an if without else (§18.5.6)
// give their condition with vpiCondition, here equality operations, and their
// expressions in order with vpiConstraintExpr (detail 3), told apart here by
// their operators; a soft constraint is an expression with vpiSoft TRUE, and
// disable soft b (§18.5.13.2) a soft disable whose expression is b. The lists
// of solve and dist items are sorted.

module test_vpi_constraint_orderings_dists;
  class pkt;
    rand int a, b, c;
    rand bit [3:0] m;
    constraint c_order { solve a before b, c; }
    constraint c_dist { a dist { 0 := 2, [1:3] :/ 6 }; }
    constraint c_impl { (m == 1) -> { b < 5; c > 6; } }
    constraint c_if { if (m == 2) b > 7; }
    constraint c_soft { soft c == 3; disable soft b; }
  endclass

  pkt p;

  initial begin
    p = new;
    $vt_structure;
    $vt_enabled("before constraint_mode(0)");
    p.c_if.constraint_mode(0);
    $vt_enabled("after constraint_mode(0) on c_if");
  end
endmodule

/*
:name: test_vpi_fork_join_type_stmts
:description: Named and unnamed forks give vpiJoinType vpiJoin, vpiJoinAny or vpiJoinNone after the keyword that ends them, and vpi_iterate(vpiStmt) of a fork gives exactly the statements in it (IEEE 1800-2023 Section 37.12)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.12 9.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_fork_join_type_stmts.c
:expected_stdout: @test_vpi_fork_join_type_stmts.expected
*/
// IEEE 1800-2023 §37.12: a named fork and a fork have the integer property
// vpiJoinType, which tells which join keyword ends the block: vpiJoin,
// vpiJoinAny or vpiJoinNone (detail 6, 9.3.2), and a one-to-many relation to
// the statements in them, traversed with vpi_iterate(vpiStmt). The six forks
// in block p, three named and three unnamed, end with each keyword once, and
// hold different numbers of assignments. The application takes the statements
// of p in the order of their lines, and for each fork prints its kind, its
// join type and the targets of its statements, sorted.

module test_vpi_fork_join_type_stmts;
  logic a, b, c, d, e, f, g, h, i, j;

  initial begin : p
    fork : fj a = 1'b1; b = 1'b1; join
    fork : fa c = 1'b1; join_any
    fork : fn d = 1'b1; e = 1'b1; f = 1'b1; join_none
    fork g = 1'b1; join
    fork h = 1'b1; i = 1'b1; join_any
    fork j = 1'b1; join_none
  end

  initial #1 $vt_forks;
endmodule

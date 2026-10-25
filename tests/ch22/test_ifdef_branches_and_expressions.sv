/*
:name: test_ifdef_branches_and_expressions
:description: Conditional compilation takes the first `ifdef, `ifndef or `elsif branch whose macro name or parenthesized expression of names with !, &&, ||, -> and <-> holds, and otherwise the `else branch, and any block of text may be empty (IEEE 1800-2023 Section 22.6)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ifdef_branches_and_expressions.expected
*/
// IEEE 1800-2023 §22.6: a conditional is `ifdef or `ifndef with a condition,
// any number of `elsif branches, an optional `else, and `endif; every block of
// text may be left out. A condition is a macro name or, in parentheses, an
// expression of names, !, &&, ||, -> and <-> and parentheses, where a defined
// name counts as 1 and any other as 0. The first branch whose condition holds
// is used, else the `else branch. A and C are defined, B and D are not. The
// chain uses its third branch; the `ifndef uses its `elsif, as B -> D holds;
// (A && !(B || D) && (C <-> A)) holds; (C -> B) and (B <-> C) do not; and the
// conditionals with empty blocks leave nothing. Each int records the branch.
// Icarus Verilog 13.0 does not accept expressions after `ifdef and `elsif, and
// the 5.052 release of Verilator takes !(B || D) as 0 and rejects (B || (C &&
// !A)).

`define A
`define C

module test_ifdef_branches_and_expressions;
`ifdef A
`endif
`ifdef B
`elsif D
`else
`endif
`ifdef B
  int chain = 1;
`elsif D
  int chain = 2;
`elsif C
  int chain = 3;
`elsif A
  int chain = 4;
`else
  int chain = 5;
`endif
`ifndef A
  int not_a = 1;
`elsif (B -> D)
  int not_a = 2;
`else
  int not_a = 3;
`endif
`ifdef (A && !(B || D) && (C <-> A))
  int all_ops = 1;
`else
  int all_ops = 0;
`endif
`ifdef (C -> B)
  int c_to_b = 1;
`elsif (B <-> C)
  int c_to_b = 2;
`else
  int c_to_b = 0;
`endif
`ifndef (B || (C && !A))
  int ifndef_expr = 1;
`else
  int ifndef_expr = 0;
`endif

  initial begin
    $display("chain=%0d not_a=%0d", chain, not_a);
    $display("all_ops=%0d c_to_b=%0d ifndef_expr=%0d", all_ops, c_to_b, ifndef_expr);
  end
endmodule

/*
:name: test_logical_operands_evaluated_once_and_unknown_left
:description: &&, || and -> always evaluate their first operand and evaluate the second when an unknown first operand leaves the result open; <-> evaluates each operand exactly once; the results are 1-bit 1, 0 or x (IEEE 1800-2023 Section 11.4.7)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.7 11.3.5
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_logical_operands_evaluated_once_and_unknown_left.expected
*/
// IEEE 1800-2023 §11.4.7: the result of &&, ||, -> and <-> is 1'b1 when
// true, 1'b0 when false and 1'bx when it cannot be decided. &&, || and ->
// always evaluate their first operand and skip the second only when the
// first one decides the result (§11.3.5); an unknown first operand decides
// nothing, so the second one is evaluated, and a false second operand of &&
// (true of ||, true of ->) then decides the result. a <-> b means
// (a -> b) && (b -> a), but each of its operands is evaluated exactly once.
// The operands are calls of lhs() and rhs(), which count their calls in nl
// and nr; each line shows the result and the two counts. The first block
// has an unknown first operand, the second a known one, so the count of rhs
// shows when the second operand is skipped while nl is always 1. The <->
// lines cover all four known pairs and an unknown operand on either side.
// $bits shows that each result has one bit.
// Icarus Verilog 13.0 evaluates the second operand of -> when the first one
// is false (0 -> 0 gives nr=1), which §11.4.7 forbids; Verilator 5.052 has no
// x value.

module test_logical_operands_evaluated_once_and_unknown_left;
  int nl, nr;

  function automatic logic lhs(logic v);
    nl++;
    return v;
  endfunction

  function automatic logic rhs(logic v);
    nr++;
    return v;
  endfunction

  task automatic show(string label, logic r);
    $display("%s = %b nl=%0d nr=%0d", label, r, nl, nr);
    nl = 0;
    nr = 0;
  endtask

  initial begin
    show("x && 0", lhs(1'bx) && rhs(1'b0));
    show("x && 1", lhs(1'bx) && rhs(1'b1));
    show("x || 1", lhs(1'bx) || rhs(1'b1));
    show("x || 0", lhs(1'bx) || rhs(1'b0));
    show("x -> 1", lhs(1'bx) -> rhs(1'b1));
    show("x -> 0", lhs(1'bx) -> rhs(1'b0));
    show("0 && 1", lhs(1'b0) && rhs(1'b1));
    show("1 && 1", lhs(1'b1) && rhs(1'b1));
    show("1 || 0", lhs(1'b1) || rhs(1'b0));
    show("0 || 0", lhs(1'b0) || rhs(1'b0));
    show("0 -> 0", lhs(1'b0) -> rhs(1'b0));
    show("1 -> 0", lhs(1'b1) -> rhs(1'b0));
    show("0 <-> 0", lhs(1'b0) <-> rhs(1'b0));
    show("0 <-> 1", lhs(1'b0) <-> rhs(1'b1));
    show("1 <-> 0", lhs(1'b1) <-> rhs(1'b0));
    show("1 <-> 1", lhs(1'b1) <-> rhs(1'b1));
    show("x <-> 1", lhs(1'bx) <-> rhs(1'b1));
    show("0 <-> x", lhs(1'b0) <-> rhs(1'bx));
    $display("bits: %0d %0d %0d %0d", $bits(8'd5 && 8'd3), $bits(8'd0 || 8'd4),
             $bits(8'd5 -> 8'd0), $bits(8'd6 <-> 8'd9));
  end
endmodule

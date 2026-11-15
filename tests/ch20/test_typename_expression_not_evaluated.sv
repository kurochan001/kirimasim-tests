/*
:name: test_typename_expression_not_evaluated
:description: $typename of an expression gives the string of its self-determined type without evaluating it, so a function call in it has no side effect and a member select through a null handle raises no error (IEEE 1800-2023 Section 20.6.1)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_typename_expression_not_evaluated.expected
*/
// IEEE 1800-2023 §20.6.1: with an expression argument, $typename returns
// the string of the self-determined type of the expression; that type is
// found during elaboration and the expression is never evaluated. The
// strings of the built-in types used here are their keywords, with the
// default signing of shortint left out.
// bump returns a shortint and counts its calls in calls, so $typename(bump())
// is "shortint" and calls stays 0; an evaluation would make it 1. The handle
// h of class holder is null, so reading h.r or h.s would be an error, but
// $typename(h.r) and $typename(h.s) are "real" and "string", and the last
// line shows that h is still null and that the run went on.
// Icarus Verilog 13.0 does not implement $typename.

class holder;
  real r;
  string s;
endclass

module test_typename_expression_not_evaluated;
  int calls = 0;
  holder h;

  function automatic shortint bump();
    calls = calls + 1;
    return 16'sd1;
  endfunction

  initial begin
    $display("call: %s", $typename(bump()));
    $display("calls = %0d", calls);
    $display("null handle: %s %s", $typename(h.r), $typename(h.s));
    $display("h == null: %0d", h == null);
  end
endmodule

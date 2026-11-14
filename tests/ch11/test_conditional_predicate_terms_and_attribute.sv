/*
:name: test_conditional_predicate_terms_and_attribute
:description: the predicate of ?: is one or more expression or "expression matches pattern" terms joined by &&&, and attribute instances may follow the ? (IEEE 1800-2023 Section 11.4.11)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11 12.6.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_conditional_predicate_terms_and_attribute.expected
*/
// IEEE 1800-2023 §11.4.11, Syntax 11-2: a conditional expression is a
// cond_predicate, ?, any number of attribute instances, the first expression,
// : and the second expression. The cond_predicate is a list of terms joined
// by &&&, each term an expression or a cond_pattern "expression matches
// pattern". §12.6.3: the terms are tested from left to right, all of them
// have to succeed, a failing term stops the test, and the identifiers bound
// by a pattern can be used in the later terms and in the first expression.
// The test uses two expression terms; a constant pattern followed by an
// expression term; a tagged union pattern that binds k, used by the next term
// and by the first expression; a failing pattern before a term that calls
// probe, which counts its calls; and an attribute instance after ?, with a
// value and without one. Each form is used once where the predicate holds
// and once where it fails, so a predicate that ignored a term or an
// attribute that changed the selection would print another value.
// Icarus Verilog 13.0 does not support tagged unions, and the 5.054 release
// of Verilator reports the &&& predicate as unsupported, so the expected
// output follows the standard.

module test_conditional_predicate_terms_and_attribute;
  typedef union tagged {
    void Invalid;
    int Valid;
  } maybe_t;

  maybe_t m1, m2;
  int v = 5;
  logic [3:0] n = 4'd3;
  int calls, r1, r2;

  function automatic bit probe();
    calls++;
    return 1'b1;
  endfunction

  initial begin
    m1 = tagged Valid (12);
    m2 = tagged Invalid;
    r1 = v > 2 &&& v < 9 ? 1 : 0;
    r2 = v > 2 &&& v > 9 ? 1 : 0;
    $display("expressions: %0d %0d", r1, r2);
    r1 = n matches 4'd3 &&& v == 5 ? 10 : 20;
    r2 = n matches 4'd4 &&& v == 5 ? 10 : 20;
    $display("constant pattern: %0d %0d", r1, r2);
    r1 = m1 matches tagged Valid .k &&& k > 10 ? k + 1 : -1;
    r2 = m2 matches tagged Valid .k &&& k > 10 ? k + 1 : -1;
    $display("tagged pattern: %0d %0d", r1, r2);
    r1 = m2 matches tagged Valid .k &&& probe() ? 1 : 2;
    $write("left to right: %0d calls=%0d", r1, calls);
    r2 = m1 matches tagged Valid .k &&& probe() ? 1 : 2;
    $display(" %0d calls=%0d", r2, calls);
    r1 = v == 5 ? (* note = "taken" *) 30 : 40;
    r2 = n matches 4'd3 &&& v != 5 ? (* note *) 30 : 40;
    $display("attribute: %0d %0d", r1, r2);
  end
endmodule

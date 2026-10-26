/*
:name: test_pattern_conditional_predicate
:description: A conditional expression whose predicate holds pattern matches clauses combined with &&& evaluates the clauses left to right and stops at the first failure, keeps a pattern binding in the later clauses and in the true branch, and combines both branches bit by bit when a Boolean clause is ambiguous (IEEE 1800-2023 Section 12.6.3)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.6.3 12.6.2 11.4.11
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_pattern_conditional_predicate.expected
*/
// IEEE 1800-2023 §12.6.3: the predicate of a conditional expression may hold
// a series of expressions and "expression matches pattern" clauses joined by
// &&&; the clauses are a left-to-right conjunction, a failing clause stops the
// evaluation of the rest, and every clause must succeed for the predicate to
// be true. Each pattern's scope extends over the remaining clauses and the
// consequent. The predicate can be true, false or ambiguous, and §11.4.11
// gives the result: for an ambiguous condition each bit of the result is the
// common bit of the two expressions, or x if they differ, so a = 4'b1010 and
// b = 4'b1100 give 4'b1xx0. The function bump counts its calls, which shows
// that the second clause is not evaluated when the first one fails.

module test_pattern_conditional_predicate;
  logic [3:0] v = 4'b1010;
  logic [3:0] a = 4'b1010;
  logic [3:0] b = 4'b1100;
  logic [3:0] r;
  logic xp;
  int calls = 0;

  function automatic bit bump();
    calls++;
    return 1'b1;
  endfunction

  initial begin
    xp = 1'bx;
    r = ((v matches .n) &&& xp) ? a : b;
    $display("ambiguous: %b", r);

    xp = 1'b1;
    r = ((v matches .n) &&& xp) ? a : b;
    $display("true: %b", r);

    xp = 1'b0;
    r = ((v matches .n) &&& xp) ? a : b;
    $display("false: %b", r);

    r = ((v matches .n) &&& (n == 4'b1010)) ? n + 1 : 4'b1111;
    $display("scope: %b", r);

    r = ((v matches 4'b0000) &&& bump()) ? a : b;
    $display("short: calls=%0d r=%b", calls, r);

    r = ((v matches 4'b1010) &&& bump()) ? a : b;
    $display("called: calls=%0d r=%b", calls, r);
  end
endmodule

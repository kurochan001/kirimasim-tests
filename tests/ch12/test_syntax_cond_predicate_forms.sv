/*
:name: test_syntax_cond_predicate_forms
:description: A conditional predicate of two and three terms joined by &&&, with expression terms and with "expression matches pattern" terms, runs its statement only when every term is true (IEEE 1800-2023 Sections 12.4 and 12.6.2, A.6.6, A.6.7.1)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4 12.6.2 A.6.6 A.6.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_cond_predicate_forms.expected
*/
// IEEE 1800-2023 A.6.6: a cond_predicate is one or more
// expression_or_cond_pattern terms joined by "&&&", and A.6.7.1 has a pattern
// term of the form "expression matches pattern". All terms of the predicate
// are true for the statement to run.
//
// The first two predicates have two expression terms, and the second is false
// in its second term and runs its else statement. The third has three
// expression terms. The fourth combines an expression term with a pattern
// term that binds the value of the enum in v. The last four use pattern terms
// alone with a constant, a parenthesized constant, a variable pattern and the
// wildcard.
//
// The expected output follows the standard; Verilator 5.052 does not support
// the &&& form of a conditional predicate, and Icarus Verilog 13.0 does not
// support expression matches pattern.

module test_syntax_cond_predicate_forms;
  typedef enum logic [1:0] {IDLE, RUN} state_t;

  int a = 1, b = 2;
  state_t st = RUN;

  initial begin
    if (a == 1 &&& b == 2) $display("two terms true");
    if (a == 1 &&& b == 3) $display("wrong"); else $display("second term false");
    if (a == 1 &&& b == 2 &&& a + b == 3) $display("three terms true");
    if (a == 1 &&& st matches .v) $display("expression and pattern");
    if (st matches RUN) $display("matches constant");
    if (st matches (RUN)) $display("matches parenthesized constant");
    if (st matches .v) $display("matches variable %0d", v);
    if (st matches .*) $display("matches wildcard");
  end
endmodule

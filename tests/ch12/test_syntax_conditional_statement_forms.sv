/*
:name: test_syntax_conditional_statement_forms
:description: if with the unique, unique0 and priority qualifiers, repeated else-if arms, an optional else arm and null statements as then or else arm chooses the first true predicate (IEEE 1800-2023 Section 12.4, A.6.6)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4 A.6.6 A.6.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_conditional_statement_forms.expected
*/
// IEEE 1800-2023 A.6.6: a conditional statement is "[ unique_priority ] if
// ( cond_predicate ) statement_or_null", any number of "else if (
// cond_predicate ) statement_or_null" arms and an optional "else
// statement_or_null"; unique_priority is unique, unique0 or priority.
// §12.4: the predicates are evaluated in order and the statement of the
// first true one runs.
//
// The function chain has three else-if arms and an else, and returns a
// different string for 0, 1, 2 and 3. A unique if with two arms takes the
// arm of its matching predicate; a unique0 if whose predicate matches nothing
// is not a violation and runs no statement; a priority if runs its matching
// arm. Null statements are used as a then arm and as an else arm and print
// nothing.

module test_syntax_conditional_statement_forms;
  function automatic string chain(int x);
    if (x == 0) return "zero";
    else if (x == 1) return "one";
    else if (x == 2) return "two";
    else return "many";
  endfunction

  int a = 1;

  initial begin
    $display("chain: %s %s %s %s", chain(0), chain(1), chain(2), chain(3));

    if (a == 1) ; else $display("wrong then");
    if (a == 2) $display("wrong else"); else ;
    $display("null arms done");

    unique if (a == 1) $display("unique first");
      else if (a == 2) $display("wrong unique second");

    unique0 if (a == 9) $display("wrong unique0");
    $display("unique0 no match");

    priority if (a == 1) $display("priority first");
      else $display("wrong priority else");
  end
endmodule

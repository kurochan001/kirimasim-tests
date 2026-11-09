/*
:name: test_coverage_statement_executed_once
:description: Statement coverage counts a statement as covered once it has executed, so the branch that has not run keeps the current value below the maximum, running covered statements again adds nothing, and running the other branch covers every statement (IEEE 1800-2023 Section 40.2.2)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.2.2 40.3.2.3 40.3.2.2 40.3.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_statement_executed_once.expected
*/
// IEEE 1800-2023 §40.2.2: a statement is covered when it has executed at least
// once; whether the items are single statements or statement blocks is left to
// the query, so the test does not fix their number. §40.3.2.3: $coverage_get
// gives the number of items covered so far, and §40.3.2.2 $coverage_get_max
// the number of items.
//
// The only statements of the instance u are those of its task step: an if
// statement and the assignments of its two branches. Nothing of u runs before
// the top module calls step, so no item is covered then. step(1) runs the if
// and its then branch, and the else branch stays uncovered, so the value is
// above zero and below the maximum. Two more calls of step(1) run the same
// statements and add nothing. step(0) runs the else branch, after which every
// statement of u has run, so the value equals the maximum. Which parts of a
// design have statement coverage depends on the tool (40.3.2.1), so the
// numbers are checked only where a check of u gives SV_COV_OK. A tool that
// counted executions would print no on the line about repeated calls.

`timescale 1ns/1ns

module test_coverage_statement_executed_once_unit;
  int n = 0;

  task automatic step(input bit up);
    if (up)
      n = n + 1;
    else
      n = n - 1;
  endtask
endmodule

module test_coverage_statement_executed_once;
  test_coverage_statement_executed_once_unit u();

  int check, max_value, at_start, after_then, after_repeat, after_else;

  function automatic string yes_no(bit ok);
    return ok ? "yes" : "no";
  endfunction

  initial begin
    #1;
    check = $coverage_control(`SV_COV_CHECK, `SV_COV_STATEMENT, `SV_COV_MODULE, u);
    max_value = $coverage_get_max(`SV_COV_STATEMENT, `SV_COV_MODULE, u);
    at_start = $coverage_get(`SV_COV_STATEMENT, `SV_COV_MODULE, u);
    u.step(1);
    after_then = $coverage_get(`SV_COV_STATEMENT, `SV_COV_MODULE, u);
    u.step(1);
    u.step(1);
    after_repeat = $coverage_get(`SV_COV_STATEMENT, `SV_COV_MODULE, u);
    u.step(0);
    after_else = $coverage_get(`SV_COV_STATEMENT, `SV_COV_MODULE, u);
    $display("check is not ERROR: %s", yes_no(check != `SV_COV_ERROR));
    $display("n after the calls: %0d", u.n);
    $display("with statement coverage of u, nothing is covered before step runs: %s",
             yes_no(check != `SV_COV_OK || at_start == 0));
    $display("with statement coverage of u, the then branch alone covers some but not all: %s",
             yes_no(check != `SV_COV_OK || (after_then > 0 && after_then < max_value)));
    $display("with statement coverage of u, running the same statements again adds nothing: %s",
             yes_no(check != `SV_COV_OK || after_repeat == after_then));
    $display("with statement coverage of u, after the else branch every item is covered: %s",
             yes_no(check != `SV_COV_OK || after_else == max_value));
  end
endmodule

/*
:name: test_immediate_assertion_truth_and_actions
:description: an immediate assert or assume is evaluated each time it is reached, takes 0, x and z as false and any nonzero known value as true like an if condition, and runs its pass statement or the statement after else at once, before the next statement (IEEE 1800-2023 Section 16.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3 12.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_immediate_assertion_truth_and_actions.expected
*/
// IEEE 1800-2023 §16.3: the expression of an immediate assertion is read as
// the condition of an if statement (§12.4): 0, x and z are false, and the
// assertion fails; any other value is true, and it passes. An assert or an
// assume runs its first statement, the pass statement, on success and the
// statement after else on failure; either one can be left out (a failing
// assert without else calls $error, whose message is not compared). The
// statements run as soon as the expression has been evaluated, so they come
// before the statement that follows the assertion, which writes " /". One
// loop reaches the same four assertions once for each of five values of v,
// all in time step 0; cond() counts how often an assertion expression is
// evaluated. Each line shows, in order, what the actions and the statements
// after the assertions wrote. The immediate cover is checked in
// test_immediate_cover_pass_statement.

module test_immediate_assertion_truth_and_actions;
  logic [3:0] vals[5] = '{4'b0000, 4'b0001, 4'b0100, 4'bxxxx, 4'bzzzz};
  logic [3:0] v;
  int evals = 0;
  string log;

  function automatic logic [3:0] cond(logic [3:0] x);
    evals++;
    return x;
  endfunction

  initial begin
    foreach (vals[i]) begin
      v = vals[i];
      log = "";
      assert (cond(v)) log = {log, " assert:pass"}; else log = {log, " assert:fail"};
      log = {log, " /"};
      assume (cond(v)) log = {log, " assume:pass"}; else log = {log, " assume:fail"};
      log = {log, " /"};
      assert (cond(v)) log = {log, " pass-only"};
      log = {log, " /"};
      assert (cond(v)) else log = {log, " else-only"};
      log = {log, " /"};
      $display("v=%b:%s", v, log);
    end
    $display("evaluations: %0d", evals);
  end
endmodule

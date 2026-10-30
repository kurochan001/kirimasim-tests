/*
:name: test_immediate_assertion_default_error
:description: a failing immediate assert or assume without an else statement calls $error, which reports the line of the assertion, unless $assertcontrol has turned fail actions off; a passing assertion and one with an else statement report nothing (IEEE 1800-2023 Section 16.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3 20.10 20.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_immediate_assertion_default_error.expected
:expected_stderr_regex: (?i)\A(?=[\s\S]*(?:error[^\n]*(?:\n[^\n]*)?test_immediate_assertion_default_error\.sv:29\b|test_immediate_assertion_default_error\.sv:29\b[^\n]*(?:\n[^\n]*)?error))(?=[\s\S]*(?:error[^\n]*(?:\n[^\n]*)?test_immediate_assertion_default_error\.sv:31\b|test_immediate_assertion_default_error\.sv:31\b[^\n]*(?:\n[^\n]*)?error))(?![\s\S]*test_immediate_assertion_default_error\.sv:32\b)(?![\s\S]*test_immediate_assertion_default_error\.sv:34\b)(?=[\s\S]*(?:error[^\n]*(?:\n[^\n]*)?test_immediate_assertion_default_error\.sv:36\b|test_immediate_assertion_default_error\.sv:36\b[^\n]*(?:\n[^\n]*)?error))(?![\s\S]*test_immediate_assertion_default_error\.sv:37\b)
*/
// IEEE 1800-2023 §16.3: when the else clause of an immediate assert or
// assume is left out, a failure calls $error, unless $assertcontrol
// suppresses it (§20.11: control type 9, FailOff, until 8, FailOn). §20.10:
// the message of $error has the severity error and names the file and line.
// The assertions at lines 29 (assert), 31 (assume) and 36 (assert, after
// FailOn) fail without an else clause, so the messages of the run have to
// name those lines with an error; the passing assertion at 32, the failing
// one at 34 while fail actions are off and the one at 37 with its own else
// statement must not be reported. Neither the wording nor the layout of the
// messages is compared. Icarus 13.0 lacks $assertcontrol.

module test_immediate_assertion_default_error;
  int x = 0;

  initial begin
    a_fail: assert (x == 1);
    $display("after a_fail");
    u_fail: assume (x == 1);
    a_pass: assert (x == 0);
    $assertcontrol(9);
    a_off: assert (x == 1);
    $assertcontrol(8);
    a_on: assert (x == 1);
    a_else: assert (x == 1) else $display("a_else: own fail statement");
    $display("done");
  end
endmodule

/*
:name: test_deferred_assertion_default_error
:description: a failing deferred assert or assume without an else statement queues a call of $error on its process like any other report, so the call is made when the report matures and is dropped when the report is flushed (IEEE 1800-2023 Section 16.4.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.4.1 16.3 16.4.2 20.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_deferred_assertion_default_error.expected
:expected_stderr_regex: (?i)\A(?![\s\S]*test_deferred_assertion_default_error\.sv:34:)(?=[\s\S]*(?:error[^\n]*test_deferred_assertion_default_error\.sv:43:|test_deferred_assertion_default_error\.sv:43:[^\n]*error))(?=[\s\S]*(?:error[^\n]*test_deferred_assertion_default_error\.sv:44:|test_deferred_assertion_default_error\.sv:44:[^\n]*error))(?![\s\S]*test_deferred_assertion_default_error\.sv:45:)
*/
// IEEE 1800-2023 §16.3: a failing assert or assume without an else clause
// calls $error. §16.4.1: for a deferred assertion that call is queued on
// the process as a pending report, like an action, and made only when the
// report matures, in the Reactive region for #0 and in the Postponed region
// for final; a flush point clears it (§16.4.2). §20.10: the message of
// $error has the severity error and names the file and line. At 1 the always
// procedure runs twice: a_flushed (line 34) fails first, and the report is
// flushed when the procedure resumes at its event control and passes. At 2
// a_kept (line 43) and u_kept (line 44) fail and are reported, and a_ok
// (line 45) passes. The messages of the run have to name lines 43 and 44
// with an error, and must not name lines 34 and 45; their wording, and
// whether the word error comes before or after the place, are not compared.

`timescale 1ns/1ns

module test_deferred_assertion_default_error;
  int y = 1;
  logic trig = 0;

  always @(trig) begin
    a_flushed: assert #0 (y == 1);
  end

  initial begin
    #1 y = 0;
    trig = 1;
    #0 y = 1;
    trig = 0;
    #1;
    a_kept: assert #0 (y == 0);
    u_kept: assume final (y == 0);
    a_ok: assert final (y == 1);
    $display("t=%0t after the deferred assertions", $time);
    #1 $display("t=%0t done", $time);
  end
endmodule

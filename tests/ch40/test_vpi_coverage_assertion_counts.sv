/*
:name: test_vpi_coverage_assertion_counts
:description: The assertion coverage properties count the attempts, successes, vacuous successes, disabled attempts, killed attempts and failures of passing, vacuous, disabled, killed and never attempted assertions, and the attempts still in progress follow from them (IEEE 1800-2023 Section 40.5.2)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.5.2 40.5.1 40.3.2.1 16.14.3 20.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_coverage_assertion_counts.c
:expected_stdout: @test_vpi_coverage_assertion_counts.expected
*/
// IEEE 1800-2023 §40.5.2: vpiAssertAttemptCovered counts the attempts,
// vpiAssertSuccessCovered the nonvacuous successes,
// vpiAssertVacuousSuccessCovered the vacuous successes,
// vpiAssertDisableCovered the attempts that reached the disabled state,
// vpiAssertKillCovered the killed attempts and vpiAssertFailureCovered the
// failures, and the attempts still in progress are attempts minus all of
// these. vpiCovered of an assertion is true only when it was attempted,
// succeeded at least once and never failed. The clock rises at
// 5, 15, 25 and 35, and the counts are read at 40. a_pass holds at every tick,
// so it is attempted four times and succeeds four times. a_vac has a false
// antecedent and so succeeds vacuously at each of its four attempts. a_dis has
// disable iff true at each attempt, so all four are disabled; §16.14.3 counts
// them as attempts but not as successes. a_fail holds the false value never, so
// each of its four attempts fails. a_kill waits for a signal that never comes;
// §20.11 $assertkill kills its one attempt at 6 and stops its checking, so it
// is attempted once and killed once. a_never has a clock that never rises and
// is never attempted. Each of these has one coverable entity, so vpiCoveredMax
// is always 1. A tool that collects no assertion coverage is left out of the
// checks of the counts, but never of the maximum.

`timescale 1ns/1ns

module test_vpi_coverage_assertion_counts;
  logic clk = 0, quiet = 0;
  bit on = 1'b1, never = 1'b0;

  int started;

  always #5 clk = ~clk;

  a_never: assert property (@(posedge quiet) on);
  a_pass: assert property (@(posedge clk) on);
  a_vac: assert property (@(posedge clk) never |-> on);
  a_dis: assert property (@(posedge clk) disable iff (on) (never |-> on));
  a_fail: assert property (@(posedge clk) never) else ;
  a_kill: assert property (@(posedge clk) on ##[1:$] never);

  initial begin
    started = $coverage_control(`SV_COV_START, `SV_COV_ASSERTION, `SV_COV_HIER,
                               test_vpi_coverage_assertion_counts);
    @(posedge clk);
    #1 $assertkill(0, a_kill);
    #34 $vt_cov(started);
    $finish;
  end
endmodule

/*
:name: test_vpi_coverage_covered_never_failed
:description: vpiCovered of an assertion handle is true only for an assertion that has been attempted, has succeeded and has never failed, so an assertion that succeeds on some attempts and fails on others is not covered (IEEE 1800-2023 Section 40.5.2)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.5.2 40.5.1 40.3.2.1 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_coverage_covered_never_failed.c
:expected_stdout: @test_vpi_coverage_covered_never_failed.expected
*/
// IEEE 1800-2023 §40.5.2: for an assertion handle, vpiCovered means that the
// assertion has been attempted, has succeeded at least once and has never
// failed; vpiAssertAttemptCovered, vpiAssertSuccessCovered and
// vpiAssertFailureCovered count its attempts, successes and failures.
//
// The clock rises at 5, 15, 25 and 35, and flip changes at every falling edge,
// so it is 1 at the rising edges at 5 and 25 and 0 at those at 15 and 35.
// a_mixed checks flip: of its four attempts two succeed and two fail, and its
// fail action counts the failures (16.14.1). a_pass checks a bit that is
// always 1 and succeeds at each attempt. At 38, after the four attempts have
// ended, the application reads the properties. a_mixed has succeeded but also
// failed, so it is not covered; a_pass is. A tool that took one success as
// enough would report a_mixed as covered. The counts exist only where the tool
// collects assertion coverage, so the application checks them only when
// $coverage_control starts that coverage with SV_COV_OK (40.3.2.1); otherwise
// it prints the same lines.

`timescale 1ns/1ns

module test_vpi_coverage_covered_never_failed;
  logic clk = 0;
  bit on = 1'b1, flip = 1'b1;
  int started, fails = 0;

  always #5 clk = ~clk;
  always @(negedge clk) flip = ~flip;

  a_pass: assert property (@(posedge clk) on);
  a_mixed: assert property (@(posedge clk) flip) else fails++;

  initial begin
    started = $coverage_control(`SV_COV_START, `SV_COV_ASSERTION, `SV_COV_HIER,
                                test_vpi_coverage_covered_never_failed);
    #38 $vt_cov(started);
    $display("fail actions of a_mixed: %0d", fails);
    $finish;
  end
endmodule

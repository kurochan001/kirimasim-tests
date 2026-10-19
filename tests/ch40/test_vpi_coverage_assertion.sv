/*
:name: test_vpi_coverage_assertion
:description: vpi_get gives 1 for vpiCoveredMax of every assertion, and, when assertion coverage is collected, the attempt, success, failure and covered counts of assertions that are never attempted, never decided, failing and passing (IEEE 1800-2023 Section 40.5.2)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.5.2 40.5.1 40.3.2.1 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_coverage_assertion.c
:expected_stdout: @test_vpi_coverage_assertion.expected
*/
// IEEE 1800-2023 §40.5.2: vpi_get(vpiCoveredMax) of an assertion handle is
// always 1. The other counts exist only where the tool collects assertion
// coverage, so the application checks them only when $coverage_control starts
// that coverage with SV_COV_OK (40.3.2.1), and prints a line only for a wrong
// value. The clock ticks at 5, 15, 25 and 35, and the counts are read at 40.
// a_never is never attempted, its clock never rising. a_open is attempted at
// each tick and never decided. a_fail is attempted at each tick, and its first
// three attempts fail. a_pass is attempted at each tick, and its first three
// attempts pass. vpiCovered is true only for an assertion that was attempted,
// succeeded and never failed. No attempt succeeds vacuously, is disabled or is
// killed, so the attempts still in progress are the attempts minus the
// successes and failures: 4 for a_open, 1 for a_fail and a_pass. a_fail has a
// fail action, so its failures print nothing (16.14.1).

`timescale 1ns/1ns

module test_vpi_coverage_assertion;
  logic clk = 0, quiet = 0;
  bit on = 1, off = 0;
  int started, fails = 0;

  always #5 clk = ~clk;

  a_never: assert property (@(posedge quiet) on ##1 on);
  a_open: assert property (@(posedge clk) on ##[1:$] off);
  a_fail: assert property (@(posedge clk) on ##1 off) else fails++;
  a_pass: assert property (@(posedge clk) on ##1 on);

  initial begin
    started = $coverage_control(`SV_COV_START, `SV_COV_ASSERTION, `SV_COV_HIER,
                                test_vpi_coverage_assertion);
    #40 $vt_coverage(started == `SV_COV_OK);
    $display("fail actions: %0d", fails);
    $finish;
  end
endmodule

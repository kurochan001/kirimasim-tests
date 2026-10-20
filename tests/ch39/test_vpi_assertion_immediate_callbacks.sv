/*
:name: test_vpi_assertion_immediate_callbacks
:description: Assertion callbacks can be placed on immediate assert, assume and cover statements, and report each execution with its time and attempt start time (IEEE 1800-2023 Section 39.4.2)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.4.2 39.3.1 16.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_immediate_callbacks.c
:expected_stdout: @test_vpi_assertion_immediate_callbacks.expected
*/
// IEEE 1800-2023 §39.4.2: the assertion callbacks can be placed on immediate
// assertions as well as on concurrent ones. $vt_watch finds the immediate
// assert, assume and cover of the design by iterating all assertions (39.3.1)
// and places cbAssertionStart, cbAssertionSuccess and cbAssertionFailure on
// the assert and the assume, and the first two on the cover, whose not
// matching is no failure (16.3). The procedure runs them when v changes: at
// 10 (v=1) all three hold, at 20 (v=0) the assert and the assume fail and the
// cover does not match, and at 30 (v=3) all hold again. An
// immediate assertion starts and ends in one execution, so the start time of
// each attempt is the time of the callback, and a failure gives the failing
// expression. The callbacks are sorted before they are printed.

`timescale 1ns/1ns

module test_vpi_assertion_immediate_callbacks;
  int v = 0;
  int fails = 0;

  always @(v) begin : check
    chk_assert: assert (v > 0) else fails++;
    chk_assume: assume (v != 0) else fails++;
    chk_cover: cover (v > 0);
  end

  initial begin
    $vt_watch;
    #10 v = 1;
    #10 v = 0;
    #10 v = 3;
    #10 $vt_report;
    $display("fail actions: %0d", fails);
  end
endmodule

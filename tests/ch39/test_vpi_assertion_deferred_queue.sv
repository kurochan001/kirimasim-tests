/*
:name: test_vpi_assertion_deferred_queue
:description: vpiAssertionReset on a deferred assertion flushes its pending report, while vpiAssertionDisable lets a queued report mature and stops later executions (IEEE 1800-2023 Section 39.5.3)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.5.3 39.5.2 39.3.1 16.4 16.4.1 37.60
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_deferred_queue.c
:expected_stdout: @test_vpi_assertion_deferred_queue.expected
*/
// IEEE 1800-2023 §39.5.3: a VPI control that discards the attempts of a
// deferred assertion also flushes its reports that are pending in the deferred
// assertion report queue; one that leaves existing attempts alone does not.
// At time 0 both deferred assertions fail, and their reports wait for the
// Observed region (16.4, 16.4.1). Before that, in the same process, $vt_control
// finds them by iterating all assertions (39.3.1), using vpiName, which is the
// statement label (37.60), and calls vpi_control with vpiAssertionReset on
// d_reset and vpiAssertionDisable on d_disable. The report of d_reset is
// flushed; the report of d_disable matures. At time 10 d_reset is executed
// again and fails, while d_disable, being disabled, starts no attempt.

`timescale 1ns/1ns

module test_vpi_assertion_deferred_queue;
  logic ok = 0;

  initial begin
    repeat (2) begin
      d_reset: assert #0 (ok) else $display("%0d: d_reset failed", $time);
      d_disable: assert #0 (ok) else $display("%0d: d_disable failed", $time);
      if ($time == 0) $vt_control;
      #10;
    end
  end
endmodule

/*
:name: test_vpi_assertion_procedural_queue
:description: A VPI control that discards the attempts of a procedural concurrent assertion also flushes its pending instance from the procedural assertion queue, while one that leaves existing attempts alone lets the pending instance mature (IEEE 1800-2023 Section 39.5.3)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.5.3 39.5.2 39.3.1 16.14.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_procedural_queue.c
:expected_stdout: @test_vpi_assertion_procedural_queue.expected
*/
// IEEE 1800-2023 §16.14.6: a concurrent assertion in an always procedure is
// put in the procedural assertion queue when the procedure reaches it, and the
// pending instance matures in the Observed region, where its attempt starts.
// §39.5.3: a VPI control that discards the current attempts of the assertion
// also flushes its pending instances; one that does not interfere with them
// leaves the queue alone. At the rising edge at 5 the procedure queues both
// assertions, whose property fails, and then $vt_control, which finds them by
// name among all assertions (39.3.1), resets p_reset and disables p_disable
// (39.5.2). The instance of p_reset is flushed; that of p_disable matures and
// fails. At 15 p_reset is queued again and fails, while p_disable, being
// disabled, starts no attempt.

`timescale 1ns/1ns

module test_vpi_assertion_procedural_queue;
  logic clk = 0, ok = 0;

  always #5 clk = ~clk;

  always @(posedge clk) begin
    p_reset: assert property (ok) else $display("%0d: p_reset failed", $time);
    p_disable: assert property (ok) else $display("%0d: p_disable failed", $time);
    if ($time == 5) $vt_control;
  end

  initial #20 $finish;
endmodule

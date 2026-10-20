/*
:name: test_procedural_assertion_no_glitch
:description: A procedural concurrent assertion in always_comb queued with a transient value is flushed when the procedure runs again in the same time step, so it does not fail (IEEE 1800-2023 Section 16.14.6.2)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.6.2 16.14.6.3 16.14.6 16.14.6.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_procedural_assertion_no_glitch.expected
*/
// IEEE 1800-2023 §16.14.6: a concurrent assertion in procedural code is
// queued with the current values of its const' expressions (16.14.6.1) and
// matures in the Observed region. §16.14.6.2, §16.14.6.3: when an always_comb
// procedure runs again in the same time step, its queue is flushed, so an
// instance queued while not_a still had its old value never matures. a
// toggles at each clock edge and not_a follows it through a continuous
// assignment, so whatever the order of these updates, every instance that
// matures sees not_a != a. The instance queued at time 0 is evaluated at the
// first edge, together with the one queued there: 4 passes by 32.

module test_procedural_assertion_no_glitch;
  logic clk = 0;
  logic a = 0;
  wire not_a;
  logic seen;
  int passes = 0, fails = 0;

  assign not_a = !a;
  always #5 clk = ~clk;
  always @(posedge clk) a <= ~a;

  always_comb begin
    seen = not_a ^ a;
    p1: assert property (@(posedge clk) const'(not_a) != const'(a)) passes++;
        else fails++;
  end

  initial begin
    #32 $display("passes=%0d fails=%0d", passes, fails);
    $finish;
  end
endmodule

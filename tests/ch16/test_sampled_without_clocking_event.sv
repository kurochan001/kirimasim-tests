/*
:name: test_sampled_without_clocking_event
:description: $sampled takes one expression and no clocking event, and returns the value the expression had in the preponed region, which in an action block differs from the value the variable has there, while the action block itself runs after the nonblocking updates of the time step (IEEE 1800-2023 Section 16.9.3, C.2.2)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.3 C.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sampled_without_clocking_event.expected
*/
// IEEE 1800-2023 §16.9.3: $sampled takes an expression and no clocking event,
// and returns the sampled value of that expression, the value it had in the
// preponed region of the time step (16.5.1). C.2.2: the clocking event
// argument of the 2005 standard is gone and the semantics no longer depend on
// a clocking event, so a call with the expression alone has that meaning.
//
// a and b are updated by nonblocking assignments at each rising edge: a takes
// b's old value and b its own complement, so in the preponed region of every
// edge a and b differ. The property a == b therefore fails at each of the
// four edges. In the action block, which runs in the Reactive region after
// the nonblocking updates, the current values of a and b have exchanged, and
// $sampled(a) and $sampled(b) still give the preponed pair. The two pairs on
// each line therefore differ, and an implementation that returned the current
// value from $sampled, or that ran the action block before the updates, would
// print two equal pairs.
//
// The expected output follows the standard. The releases that can parse the
// test print the current value in both places and run the action block before
// the nonblocking updates, so neither reproduces it; see the simulator
// difference note of this work.

module test_sampled_without_clocking_event;
  logic clk = 0;
  logic a = 0;
  logic b = 1;
  int fails = 0;

  always #5 clk = ~clk;

  always @(posedge clk) begin
    a <= b;
    b <= ~b;
  end

  ap: assert property (@(posedge clk) a == b)
      else begin
        fails++;
        $display("fail %0d: sampled a b = %b %b, current a b = %b %b",
                 fails, $sampled(a), $sampled(b), a, b);
      end

  initial begin
    repeat (4) @(posedge clk);
    #1 $display("fails %0d", fails);
    $finish;
  end
endmodule

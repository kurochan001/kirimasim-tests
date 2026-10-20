/*
:name: test_past_deep_history
:description: $past with a number of ticks of 30 returns the sampled value of 30 clock ticks before, and the default sampled value while there is less history (IEEE 1800-2023 Section 16.9.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.3 16.5.1 16.14.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_past_deep_history.expected
*/
// IEEE 1800-2023 §16.9.3: $past(e, n) is the sampled value of e at the n-th
// clock tick before the current one; while fewer than n ticks have passed it
// is the default sampled value (16.5.1), here the initial value 0. cnt goes
// up by one at each edge, so its sampled value at tick k is k - 1 and
// $past(cnt, 30) is cnt - 30 from tick 31 on and 0 before: the assertion
// passes at all 40 ticks. In the always procedure the clock of $past is
// inferred (16.14.7): at tick 40, $past(cnt) is 38 and $past(cnt, 30) is 9.

module test_past_deep_history;
  logic clk = 0;
  int cnt = 0, tick = 0;
  int passes = 0, fails = 0;

  always #5 clk = ~clk;

  always @(posedge clk) begin
    tick++;
    cnt <= cnt + 1;
    if (tick == 40)
      $display("tick 40: $past(cnt) = %0d, $past(cnt, 30) = %0d", $past(cnt), $past(cnt, 30));
  end

  a_deep: assert property (@(posedge clk) $past(cnt, 30) == (cnt >= 30 ? cnt - 30 : 0))
    passes++;
    else fails++;

  initial begin
    #405 $display("passes=%0d fails=%0d", passes, fails);
    $finish;
  end
endmodule

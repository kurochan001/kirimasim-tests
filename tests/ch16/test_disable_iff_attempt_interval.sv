/*
:name: test_disable_iff_attempt_interval
:description: an evaluation attempt of a property with disable iff is disabled, and neither passes nor fails, exactly when the current value of the disable condition is true at some time from the Observed region of its first tick to its last tick, both included; each attempt is judged on its own interval (IEEE 1800-2023 Section 16.12)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12 16.12.7 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_disable_iff_attempt_interval.expected
*/
// IEEE 1800-2023 §16.12: if the disable condition is true at any time from
// the start of an attempt in the Observed region, inclusive, to the end of
// the attempt, inclusive, the attempt is disabled and gives neither success
// nor failure; otherwise its result is that of the property. The condition
// uses current values, not sampled ones, and is tested for each attempt on
// its own. a_dis checks start |-> ##2 1'b0 (§16.12.7), so every attempt from
// a tick with start would fail two ticks later; its fail action (§16.14.1)
// records the time. Ticks are at 10k + 5. The attempts from 15 to 35, 55 to
// 75 and 95 to 115 are disabled by rst high from 24 to 26, inside the
// interval, from 55, in the time step of the first tick, and from 115, in
// that of the last one. rst high from 131 until it is cleared at 135, in the
// time step of the first tick before the Observed region, and high from 196,
// after the end at 195, leaves the attempts from 135 and 175. Of the attempts
// from 215 and 225, only the second is disabled by rst high at 238 and 239.

`timescale 1ns/1ns

module test_disable_iff_attempt_interval;
  logic clk = 0, start = 0, rst = 0;
  int f_dis[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_dis: assert property (@(posedge clk) disable iff (rst) start |-> ##2 1'b0)
    else f_dis.push_back($time);

  function automatic string times(int t[$]);
    string str = "";
    foreach (t[i]) str = {str, $sformatf(" %0d", t[i])};
    return str;
  endfunction

  // start is sampled high at the ticks at 15, 55, 95, 135, 175, 215 and 225.
  initial begin
    #10 start = 1;
    #10 start = 0;    // 20
    #30 start = 1;    // 50
    #10 start = 0;    // 60
    #30 start = 1;    // 90
    #10 start = 0;    // 100
    #30 start = 1;    // 130
    #10 start = 0;    // 140
    #30 start = 1;    // 170
    #10 start = 0;    // 180
    #30 start = 1;    // 210
    #20 start = 0;    // 230
  end

  initial begin
    #24 rst = 1;
    #2 rst = 0;       // 26
    #29 rst = 1;      // 55
    #2 rst = 0;       // 57
    #58 rst = 1;      // 115
    #2 rst = 0;       // 117
    #14 rst = 1;      // 131
    #4 rst = 0;       // 135
    #61 rst = 1;      // 196
    #2 rst = 0;       // 198
    #40 rst = 1;      // 238
    #1 rst = 0;       // 239
    #21;              // 260
    $display("a_dis failures:%s", times(f_dis));
    $finish;
  end
endmodule

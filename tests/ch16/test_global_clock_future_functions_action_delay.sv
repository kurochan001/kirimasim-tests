/*
:name: test_global_clock_future_functions_action_delay
:description: with an assertion clock twice as slow as the global clock, $future_gclk, $rising_gclk, $falling_gclk and $steady_gclk look at the next global clock tick and delay the action block to it, $stable_gclk equals $stable with @$global_clock and its action is not delayed, and disable iff or a kill after the assertion tick does not affect the attempt (IEEE 1800-2023 Section 16.9.4)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_global_clock_future_functions_action_delay.expected
*/
// IEEE 1800-2023 §16.9.4: $future_gclk(v) is the sampled value of v at the
// next global clock tick after the time step of the call. $rising_gclk and
// $falling_gclk are true when the LSB of the sampled value changes to 1 or
// to 0 at that tick, $steady_gclk when the whole value stays the same.
// $stable_gclk(v) is $stable(v, @$global_clock), a past function. The
// action block of an assertion with a future function runs at the global
// tick after the last assertion tick of the attempt, but the attempt itself
// ends at that assertion tick: disable iff and a kill act only within that
// interval.
// The global clock ticks at 5, 15, 25, ...; the assertion clock at 25, 45,
// 65, 85 and 105. v is sampled as 10, 01, 11, 11, 01, 11, 11, 10, 00, 00 at
// the global ticks 25 to 115. rst is high from 47 to 53, after the attempt
// at 45, and from 63 to 67, during the attempt at 65. a_kill is killed at
// 88, after its tick at 85, and turned on again at 90. Each action adds
// time:P or time:F to the list of its assertion; the lists are printed at
// 120.
// Icarus Verilog 13.0 does not support these assertions. Verilator 5.052
// rejects the clocking event argument of $stable; without it, it takes the
// future functions from the sampled values at the assertion tick and runs
// their actions at that tick.

`timescale 1ns/1ns

module test_global_clock_future_functions_action_delay;
  logic gclk = 0, clk = 0, rst = 0;
  logic [1:0] v = 2'b00;
  string m[string];
  string order[] = '{"future v[0]", "future v[1]", "rising", "falling", "steady", "stable_gclk",
                      "stable @$global_clock", "disable iff", "kill"};

  global clocking gc @(posedge gclk); endclocking

  function automatic void hit(string name, string r);
    string t = $sformatf(" %0t:%s", $time, r);
    if (m.exists(name)) m[name] = {m[name], t};
    else m[name] = t;
  endfunction

  function automatic string ends(string name);
    return m.exists(name) ? m[name] : "";
  endfunction

  always #5 gclk = ~gclk;   // global ticks at 5, 15, 25, ...

  initial begin             // assertion ticks at 25, 45, 65, ...
    #25;
    forever begin
      clk = 1;
      #10 clk = 0;
      #10;
    end
  end

  a_f0: assert property (@(posedge clk) $future_gclk(v[0]))
    hit("future v[0]", "P"); else hit("future v[0]", "F");
  a_f1: assert property (@(posedge clk) $future_gclk(v[1]))
    hit("future v[1]", "P"); else hit("future v[1]", "F");
  a_rise: assert property (@(posedge clk) $rising_gclk(v))
    hit("rising", "P"); else hit("rising", "F");
  a_fall: assert property (@(posedge clk) $falling_gclk(v))
    hit("falling", "P"); else hit("falling", "F");
  a_steady: assert property (@(posedge clk) $steady_gclk(v))
    hit("steady", "P"); else hit("steady", "F");
  a_stable: assert property (@(posedge clk) $stable_gclk(v))
    hit("stable_gclk", "P"); else hit("stable_gclk", "F");
  a_stable_ref: assert property (@(posedge clk) $stable(v, @$global_clock))
    hit("stable @$global_clock", "P"); else hit("stable @$global_clock", "F");
  a_dis: assert property (@(posedge clk) disable iff (rst) $future_gclk(v[0]))
    hit("disable iff", "P"); else hit("disable iff", "F");
  a_kill: assert property (@(posedge clk) $future_gclk(v[0]))
    hit("kill", "P"); else hit("kill", "F");

  initial begin
    #20 v = 2'b10;   // sampled at 25
    #10 v = 2'b01;   // 35
    #10 v = 2'b11;   // 45
    #10 v = 2'b11;   // 55
    #10 v = 2'b01;   // 65
    #10 v = 2'b11;   // 75
    #10 v = 2'b11;   // 85
    #10 v = 2'b10;   // 95
    #10 v = 2'b00;   // 105 and later
  end

  initial begin
    #47 rst = 1;
    #6 rst = 0;
    #10 rst = 1;     // 63
    #4 rst = 0;      // 67
    #21 $assertkill(0, a_kill);   // 88
    #2 $asserton(0, a_kill);      // 90
    #30;             // 120
    foreach (order[i]) $display("%s: [%s ]", order[i], ends(order[i]));
    $finish;
  end
endmodule

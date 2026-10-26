/*
:name: test_global_clock_future_action_delay
:description: An assertion that contains a future global clocking sampled value function uses the value at the next global clock tick, and its action block runs at the global clock tick that follows the last tick of the assertion clock, not at the assertion clock tick (IEEE 1800-2023 Section 16.9.4)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.4 14.14
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_global_clock_future_action_delay.expected
*/
// IEEE 1800-2023 §16.9.4: $future_gclk(v) is the sampled value of v at the
// next global clock tick, and the execution of the action block of an
// assertion that contains a future global clocking sampled value function is
// delayed until the global clocking tick that follows the last tick of the
// assertion clock. §14.14: the global clocking declaration names the event
// that $global_clock denotes. The assertion clock ca rises at 5, 15, 25 and
// 35; the global clock gclk rises at 10, 20, 30 and 40. sig is 0 at the gclk
// ticks 10 and 30 and 1 at 20 and 40. The attempt that starts at 5 reads sig
// at 10, the attempt at 15 reads it at 20, and so on. a_next passes when that
// value is 1 and fails when it is 0; a_low checks the opposite. The action
// times are 10, 20, 30 and 40, one global tick after each attempt started,
// and never 5, 15, 25 or 35.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 does not support global clocking, so the expected values come from
// the cited clauses.

`timescale 1ns/1ns

module test_global_clock_future_action_delay;
  logic ca = 0, gclk = 0, sig = 0;
  int npass[$], nfail[$], lpass[$], lfail[$];

  global clocking gck @(posedge gclk); endclocking

  always #5 ca = ~ca;   // rising edges at 5, 15, 25 and 35

  initial begin
    gclk = 0;
    #5;
    forever #5 gclk = ~gclk;   // rising edges at 10, 20, 30 and 40
  end

  initial begin
    #9 sig = 0;
    #10 sig = 1;
    #10 sig = 0;
    #10 sig = 1;
  end

  a_next: assert property (@(posedge ca) $future_gclk(sig))
    npass.push_back($time); else nfail.push_back($time);
  a_low: assert property (@(posedge ca) $future_gclk(!sig))
    lpass.push_back($time); else lfail.push_back($time);

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    #48;
    $display("future sig passes:%s; failures:%s", times(npass), times(nfail));
    $display("future !sig passes:%s; failures:%s", times(lpass), times(lfail));
    $finish;
  end
endmodule

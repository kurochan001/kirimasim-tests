/*
:name: test_timing_setup_hold_notifier
:description: $setup and $hold toggle their notifiers for data changes inside their windows and not at the excluded end points (IEEE 1800-2023 Section 31.3.1)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.3.1 31.3.2 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_setup_hold_notifier.expected
*/
// IEEE 1800-2023 §31.3.1: $setup(d, posedge clk, 3, n) reports a violation when
// d changes strictly within the 3 time units before the clock edge; a change
// exactly 3 before it is outside the window. §31.3.2: $hold(posedge clk, d, 2,
// n) reports one when d changes at the clock edge or less than 2 after it; a
// change exactly 2 after it is outside the window. §31.6: each violation toggles
// the notifier, from 0 to 1 and from 1 to 0. The notifiers start at 0 so that
// their first value after a violation is fixed. The test prints the notifiers
// whenever they change.

`timescale 1ns/1ns

module timing_setup_hold(input clk, input d);
  reg ns = 0, nh = 0;
  specify
    $setup(d, posedge clk, 3, ns);
    $hold(posedge clk, d, 2, nh);
  endspecify
endmodule

module test_timing_setup_hold_notifier;
  reg clk = 0, d = 0;

  timing_setup_hold u(clk, d);

  always @(u.ns or u.nh) $display("%0d: setup notifier=%b hold notifier=%b", $time, u.ns, u.nh);

  initial begin
    #10 clk = 1;        // 10
    #2 d = 1;           // 12: exactly 2 after the edge: no hold violation
    #3 clk = 0;
    #3 d = 0;           // 18: 2 before the edge at 20: setup violation
    #2 clk = 1;         // 20
    #1 d = 1;           // 21: 1 after the edge: hold violation
    #4 clk = 0;
    #2 d = 0;           // 27: exactly 3 before the edge at 30: no setup violation
    #3 clk = 1;         // 30
    #1 d = 1;           // 31: hold violation
    #4 clk = 0;
    #10 $finish;
  end
endmodule

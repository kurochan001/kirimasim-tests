/*
:name: test_timing_nochange_window_endpoints
:description: $nochange reports a data change strictly inside the level of its reference event, not one at the leading or trailing edge, and a positive start offset moves the window earlier (IEEE 1800-2023 Section 31.4.6)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.4.6 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_nochange_window_endpoints.expected
*/
// IEEE 1800-2023 §31.4.6: $nochange(posedge clk, d, start, end) reports a
// violation when d changes strictly between the rising edge of clk minus the
// start offset and its falling edge plus the end offset; the end points are
// not part of the window. With offsets 0, changes of d at the edges at 10 and
// 20 are not violations and the one at 15 is. With a start offset of 3, the
// window of the second check opens at 7, so its data change at 8 is a
// violation and the one at 7 of the first pulse is not. §31.6: a violation
// toggles the notifier. The test prints the first notifier when it changes,
// and both at the end.
// Icarus Verilog 13.0 and Verilator 5.052 skip timing checks, so the notifiers
// never change (docs/simulator-differences.md).

`timescale 1ns/1ns

module timing_nochange_window(input clk, input d, input e);
  reg n1 = 0, n2 = 0;
  specify
    $nochange(posedge clk, d, 0, 0, n1);
    $nochange(posedge clk, e, 3, 0, n2);
  endspecify
endmodule

module test_timing_nochange_window_endpoints;
  reg clk = 0, d = 0, e = 0;

  timing_nochange_window u(clk, d, e);

  always @(u.n1) $display("%0d: n1=%b", $time, u.n1);

  initial begin
    #7 e = 1;          // 7: start of the extended window, not inside
    #3 clk = 1; d = 1; // 10: rising edge with a change of d
    #5 d = 0;          // 15: inside the window of n1
    #5 clk = 0; d = 1; // 20: falling edge with a change of d
    #5 d = 0;          // 25: clk is low
    #13 e = 0;         // 38: inside the extended window of the next pulse
    #2 clk = 1;        // 40
    #10 clk = 0;       // 50
    #10 $display("end: n1=%b n2=%b", u.n1, u.n2);
  end
endmodule

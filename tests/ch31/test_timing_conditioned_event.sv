/*
:name: test_timing_conditioned_event
:description: A timing check with a conditioned event &&& runs only while the condition is 1, and an x condition does not enable it (IEEE 1800-2023 Section 31.7)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.7 31.3.1 31.6
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_timing_conditioned_event.expected
*/
// IEEE 1800-2023 §31.7: in $setup(d, posedge clk &&& en, 3, n) the reference
// event counts only when en is true at the clock edge. A condition written as a
// plain signal is a deterministic comparison, so an x on en does not enable the
// check. The same setup violation (d changing 2 before the edge, 31.3.1) is
// therefore reported only for the edge where en is 1, and the notifier (31.6),
// which starts at 0, changes once.

`timescale 1ns/1ns

module timing_conditioned(input clk, input d, input en);
  reg n = 0;
  specify
    $setup(d, posedge clk &&& en, 3, n);
  endspecify
endmodule

module test_timing_conditioned_event;
  reg clk = 0, d = 0, en = 0;

  timing_conditioned u(clk, d, en);

  always @(u.n) $display("%0d: notifier=%b", $time, u.n);

  initial begin
    #18 d = 1;          // 18
    #2 clk = 1;         // 20, en = 0: not checked
    #5 clk = 0;
    en = 1;
    #3 d = 0;           // 28
    #2 clk = 1;         // 30, en = 1: setup violation
    #5 clk = 0;
    en = 1'bx;
    #3 d = 1;           // 38
    #2 clk = 1;         // 40, en = x: not checked
    #5 clk = 0;
    #10 $display("end: notifier=%b", u.n);
    $finish;
  end
endmodule

/*
:name: test_timing_setuphold
:description: $setuphold reports a data change strictly after the setup limit before the clock edge up to the edge, or at the edge and up to, not including, the hold limit after it, reports simultaneous changes once, and never reports anything when both limits are zero (IEEE 1800-2023 Section 31.3.3)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.3.3 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_setuphold.expected
*/
// IEEE 1800-2023 §31.3.3: with positive limits, $setuphold(posedge clk, d, 3,
// 2, n) reports a d change that comes first with the clk edge less than 3
// later, and a d change that comes second at the edge or less than 2 after it;
// the outer end of each window is not part of it, and simultaneous changes
// are a violation. With both limits zero it never reports a violation.
// §31.6: each violation toggles the notifier. The test records when each
// notifier changes. The clk edges are at 10, 20, 30 and 40; d changes at 12
// (exactly 2 after), 18 (2 before), 21 (1 after), 27 (exactly 3 before) and
// 40 (together with the edge).

`timescale 1ns/1ns

module timing_setuphold(input clk, input d);
  reg n = 0, n_zero = 0;
  specify
    $setuphold(posedge clk, d, 3, 2, n);
    $setuphold(posedge clk, d, 0, 0, n_zero);
  endspecify
endmodule

module test_timing_setuphold;
  reg clk = 0, d = 0;
  int t_n[$], t_zero[$];

  timing_setuphold u(clk, d);

  always @(u.n) t_n.push_back($time);
  always @(u.n_zero) t_zero.push_back($time);

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    #10 clk = 1;              // 10
    #2 d = 1;                 // 12: exactly 2 after the edge
    #3 clk = 0;
    #3 d = 0;                 // 18: 2 before the edge at 20
    #2 clk = 1;               // 20
    #1 d = 1;                 // 21: 1 after the edge
    #4 clk = 0;
    #2 d = 0;                 // 27: exactly 3 before the edge at 30
    #3 clk = 1;               // 30
    #5 clk = 0;
    #5 clk = 1; d = 1;        // 40: together with the edge
    #5 clk = 0;
    #10;
    $display("limits 3 and 2:%s", times(t_n));
    $display("limits 0 and 0:%s", times(t_zero));
    $finish;
  end
endmodule

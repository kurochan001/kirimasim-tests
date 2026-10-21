/*
:name: test_clocking_block_other_clock_assertion
:description: a clocking block input used in an assertion on another clock keeps the value the clocking block sampled at its own last event, instead of being sampled again by the assertion, and a clocking block name can be the clock of an assertion (IEEE 1800-2023 Section 16.18)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.18 16.5.1 14.13 14.10 16.14.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_block_other_clock_assertion.expected
*/
// IEEE 1800-2023 §16.18: a clocking block variable used in a concurrent
// assertion is sampled only by the clocking block; its sampled value is the
// one the clocking block produced (§16.5.1), which is the value it sampled
// at its most recent clocking event (§14.13). cb_neg samples a at the
// falling edges of clk, 5, 15, 25, ...; the assertions on posedge clk check
// at 10, 20, 30, ... . a rises at 17 and falls at 37, between a falling and
// a rising edge, so a_plain sees the new value at the next rising edge,
// while a_cb sees it only after the next falling edge has sampled it, one
// rising edge later. a_cbclk uses the clocking block event as its clock
// (§14.10) and checks a at the falling edges. The fail actions (§16.14.1)
// record the times.

`timescale 1ns/1ns

module test_clocking_block_other_clock_assertion;
  logic clk = 1, a = 0;
  int f_plain[$], f_cb[$], f_cbclk[$];

  always #5 clk = ~clk;   // falling edges at 5, 15, 25, ...; rising at 10, 20, ...

  clocking cb_neg @(negedge clk);
    input a;
  endclocking

  a_plain: assert property (@(posedge clk) a) else f_plain.push_back($time);
  a_cb: assert property (@(posedge clk) cb_neg.a) else f_cb.push_back($time);
  a_cbclk: assert property (@(cb_neg) a) else f_cbclk.push_back($time);

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    #17 a = 1;
    #20 a = 0;
    #16;
    $display("a on posedge clk, failures:%s", times(f_plain));
    $display("cb_neg.a on posedge clk, failures:%s", times(f_cb));
    $display("a on cb_neg, failures:%s", times(f_cbclk));
    $finish;
  end
endmodule

/*
:name: test_assertion_gated_clock_current_value
:description: the gating expression of an assertion clock posedge clk iff en uses the current value of en while the assertion expression uses its sampled value, and a sequence used as the clocking event ticks where its match ends (IEEE 1800-2023 Section 16.5.2)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.5.2 16.5.1 9.4.2.3 16.14.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertion_gated_clock_current_value.expected
*/
// IEEE 1800-2023 §16.5.2: the clocking event of an assertion uses current
// values, the assertion expression sampled values (§16.5.1), and a gated
// clock can be written clk iff en, which ticks only when en is true as clk
// rises (§9.4.2.3). A sequence can also be the clocking event: with s_rise
// being @(posedge clk) 1, @(s_rise) behaves as @(posedge clk). One process
// sets en and then raises clk in the same time step, at 10, 20, 30, 40 and
// 50, with en 1, 0, 1, 1, 0. The gated clock ticks at 10, 30 and 40, where
// the sampled en is the value set one edge before: 0, 0 and 1. The ungated
// assertions see the sampled en 0, 1, 0, 1, 1 at the five edges. The action
// blocks (§16.14.1) record the times.

`timescale 1ns/1ns

module test_assertion_gated_clock_current_value;
  logic clk = 0, en = 0;
  int p_gated[$], f_gated[$], p_plain[$], f_plain[$], p_seq[$], f_seq[$];

  sequence s_rise;
    @(posedge clk) 1'b1;
  endsequence

  a_gated: assert property (@(posedge clk iff en) en) p_gated.push_back($time);
    else f_gated.push_back($time);
  a_plain: assert property (@(posedge clk) en) p_plain.push_back($time);
    else f_plain.push_back($time);
  a_seq: assert property (@(s_rise) en) p_seq.push_back($time);
    else f_seq.push_back($time);

  // Sets en, then raises clk in the same time step.
  task automatic edge_with(logic e);
    en = e;
    clk = 1;
    #5 clk = 0;
    #5;
  endtask

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    #10;
    edge_with(1); edge_with(0); edge_with(1); edge_with(1); edge_with(0);
    $display("@(posedge clk iff en) en: passes%s, failures%s", times(p_gated), times(f_gated));
    $display("@(posedge clk) en: passes%s, failures%s", times(p_plain), times(f_plain));
    $display("@(s_rise) en: passes%s, failures%s", times(p_seq), times(f_seq));
    $finish;
  end
endmodule

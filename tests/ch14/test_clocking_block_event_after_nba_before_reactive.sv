/*
:name: test_clocking_block_event_after_nba_before_reactive
:description: The clocking block event is triggered in the Observed region, so a module process waiting for it runs after the nonblocking assignments of the clock edge but before the program processes woken by that edge, unlike a process waiting for the edge itself (IEEE 1800-2023 Section 14.10)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.10 4.4.2 24.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_block_event_after_nba_before_reactive.expected
*/
// IEEE 1800-2023 §14.10: when a clocking block processes its clocking
// event, it triggers the event named after the block in the Observed
// region. A module process waiting for @(cb) runs in the first Active
// region after that Observed region, which is not the region of a process
// waiting for the clock edge itself.
//
// At the posedge at 5:
//   - an always procedure does q <= q + 1, which updates q in the NBA
//     region, before the Observed region;
//   - a program process waiting for the edge sets pv = 1; program processes
//     run in the Reactive region (24.3.1), after the Observed region and the
//     Active region that follows it (4.4.2);
//   - a module process waiting for posedge clk reads q in the Active region
//     of the edge, before the NBA update: it sees 0;
//   - a module process waiting for @(cb) sees q = 1 and still pv = 0.
//
// Simulator note: in a run with Verilator 5.052 the @(cb) waiter sees
// pv = 1, because the program process does not wait for the Reactive
// region there; the q values match.

`timescale 1ns/1ns

program marker (input logic clk, output logic pv);
  initial begin
    pv = 1'b0;
    @(posedge clk);
    pv = 1'b1;
  end
endprogram

module test_clocking_block_event_after_nba_before_reactive;
  logic clk = 0;
  int q = 0;
  logic pv;
  int raw_q = -1, cb_q = -1, cb_pv = -1;

  always #5 clk = ~clk;

  always @(posedge clk) q <= q + 1;

  clocking cb @(posedge clk);
  endclocking

  marker m (clk, pv);

  initial begin
    @(posedge clk);
    raw_q = q;
  end

  initial begin
    @(cb);
    cb_q = q;
    cb_pv = pv;
  end

  initial begin
    #6;
    $display("waiting for posedge clk: q=%0d", raw_q);
    $display("waiting for @(cb): q=%0d pv=%0d", cb_q, cb_pv);
    $display("at 6: q=%0d pv=%0d", q, pv);
    $finish;
  end
endmodule

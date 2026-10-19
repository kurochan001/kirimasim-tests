/*
:name: test_clocking_synchronous_events
:description: @(cb) waits for the clocking event, and @(cb.x), @(posedge cb.x) and @(negedge cb.v[i]) wait for changes of the values sampled at clocking events, so a pulse between two clock edges is not seen; the index is evaluated when the event control starts, and other modules reach the clockvars by hierarchical names (IEEE 1800-2023 Sections 14.15, 14.7)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.15 14.7 14.13 14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_synchronous_events.expected
*/
// IEEE 1800-2023 §14.15: an event control on a clocking block waits for its
// clocking event; on a clocking block input, or a slice of one, it waits for
// a change of the synchronous value, the value sampled at a clocking event
// (§14.13), so it can only resume at a clock edge. A dynamic index is
// evaluated once when the event control executes. §14.7: the clockvars are
// reached as cb.name, also with a hierarchical name from another module.
// The clock rises at 5, 15, 25, ...; ack rises at 12, en rises at 22, v[2]
// falls at 32 after idx has changed to 0, ack is low from 41 to 43, between
// two edges, and falls at 52.

`timescale 1ns/1ns

module watcher;
  initial #60 $display("watcher: cb.v = %b", test_clocking_synchronous_events.cb.v);
endmodule

module test_clocking_synchronous_events;
  logic clk = 0, ack = 0, en = 0;
  logic [3:0] v = 4'b0111;
  int idx = 2;

  always #5 clk = ~clk;

  clocking cb @(posedge clk);
    input ack, en, v;
  endclocking

  watcher w();

  initial begin
    @(cb);
    $display("%0d: @(cb)", $time);
    @(cb.ack);
    $display("%0d: @(cb.ack), cb.ack = %b", $time, cb.ack);
    @(posedge cb.en);
    $display("%0d: @(posedge cb.en)", $time);
    @(negedge cb.v[idx]);
    $display("%0d: @(negedge cb.v[idx]), cb.v = %b", $time, cb.v);
    @(cb.ack);
    $display("%0d: @(cb.ack), cb.ack = %b", $time, cb.ack);
  end

  initial begin
    #12 ack = 1;      // 12
    #10 en = 1;       // 22
    #8 idx = 0;       // 30, after @(negedge cb.v[idx]) has started
    #2 v[2] = 0;      // 32
    #9 ack = 0;       // 41
    #2 ack = 1;       // 43
    #9 ack = 0;       // 52
    #18 $finish;
  end
endmodule

/*
:name: test_global_clock_past_functions_procedural_action
:description: the past global clocking functions $past_gclk, $rose_gclk, $fell_gclk, $stable_gclk and $changed_gclk can be called in procedural code and in the action block of an assertion, where they compare the sampled values of the current and the previous global clock tick (IEEE 1800-2023 Section 16.9.4)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_global_clock_past_functions_procedural_action.expected
*/
// IEEE 1800-2023 §16.9.4: $past_gclk(v) is $past(v,,, @$global_clock), and
// $rose_gclk, $fell_gclk, $stable_gclk and $changed_gclk are $rose, $fell,
// $stable and $changed with @$global_clock. Unlike the future functions,
// they are ordinary sampled value functions and can be used in procedural
// code and in action blocks (§16.9.3). They use sampled values, so a change
// of v made by a nonblocking assignment at a tick is seen only at the next
// tick; before the first tick the default sampled value, the initial 0 of
// v, is used.
// The global clock rises at 5, 15, ..., 45. At each tick v gets the next
// value of 1, 1, 0, 1, 0 by a nonblocking assignment, so its sampled values
// at the ticks are 0, 1, 1, 0, 1. The always procedure prints the five
// functions at each tick, and then the action block of an assertion that
// always passes prints them again, in the Reactive region.

`timescale 1ns/1ns

module test_global_clock_past_functions_procedural_action;
  logic gclk = 0, v = 0;
  bit tbl[5] = '{1, 1, 0, 1, 0};
  int k = 0;

  global clocking gc @(posedge gclk); endclocking

  always #5 gclk = ~gclk;   // rising edges at 5, 15, ..., 45

  always @(posedge gclk) begin
    v <= tbl[k];
    k <= k + 1;
  end

  always @(posedge gclk)
    $display("%0t procedure: past %b rose %b fell %b stable %b changed %b", $time,
             $past_gclk(v), $rose_gclk(v), $fell_gclk(v), $stable_gclk(v), $changed_gclk(v));

  a_act: assert property (@(posedge gclk) 1'b1)
    $display("%0t action: past %b rose %b fell %b stable %b changed %b", $time,
             $past_gclk(v), $rose_gclk(v), $fell_gclk(v), $stable_gclk(v), $changed_gclk(v));

  initial #48 $finish;
endmodule

/*
:name: test_ch16_sim_checker_history
:description: past and future references to an active free checker variable take its Postponed value at the corresponding tick, which the checker compares with the values it records at each tick (IEEE 1800-2023 Sections 16.5.1 and 17.7)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.5.1 17.7 16.9.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ch16_sim_checker_history.expected
*/
// IEEE 1800-2023 §16.5.1: the sampled value of an active free checker
// variable is its current value, but when a past or a future value of such
// a variable is referenced by a sampled value function, the value is taken
// in the Postponed region of the corresponding past or future clock tick.
// §17.7: a free checker variable is a checker variable declared rand. The
// assume statement m1 references v, so v is in the assume set and is given a
// value at every tick; it is not on the left-hand side of any assignment, so
// it stays active. The action block of ap records the current value of v at
// each tick in seen; at the next tick $past(v) must equal the recorded
// value, because the Postponed value of the tick where it was recorded is
// the value it had then. The action block of af records the future value at
// each tick in fut; at the next tick it must equal the current value of v,
// because the future value is the Postponed value of that next tick. The
// last tick is not asked for a future value, whose tick does not exist. The
// random values themselves are not printed, so the output does not depend on
// the random seed.
// Neither simulator can run this test: Icarus Verilog 13.0 does not support
// checkers at all and Verilator 5.052 reports "Unsupported: checker rand".
// The expected output is the behavior that §16.5.1 defines.

`timescale 1ns/1ns

checker hist(logic clk);
  rand bit v;
  global clocking gclk @(posedge clk); endclocking
  default clocking @(posedge clk); endclocking
  bit seen[$], fut[$];
  int ticks = 0, mismatches = 0;

  m1: assume property (v inside {0, 1});

  ap: assert property (1'b1) begin
        if (seen.size() > 0 && $past(v) != seen[$]) mismatches++;
        seen.push_back(v);
        ticks++;
      end

  af: assert property (1'b1) begin
        if (fut.size() > 0 && fut[$] != v) mismatches++;
        if ($time < 35) fut.push_back($future_gclk(v));
      end
endchecker

module test_ch16_sim_checker_history;
  logic clk = 0;
  hist h1(clk);

  always #5 clk = ~clk;

  initial begin
    #40;
    $display("ticks=%0d mismatches=%0d", h1.ticks, h1.mismatches);
    $finish;
  end
endmodule

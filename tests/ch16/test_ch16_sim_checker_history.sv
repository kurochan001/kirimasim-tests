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
// the value it had then. af takes the future value of v in its property
// expression and saves it in saved_future. §16.9.4 allows a global clocking
// future sampled value function only in a sequence or property expression,
// and not in an assertion that has a sequence match item, and it runs the
// action block of such an assertion at the next global clock tick. The action
// block of af therefore runs at the tick whose Postponed value the future
// function returned, and it compares saved_future with the current value of v
// there; the two must be equal. The value of the last tick is not compared,
// because its action block runs after the test prints its result. The random
// values themselves are not printed, so the output does not depend on the
// random seed. §17.7 also does not allow a module to read a checker variable
// hierarchically, so the two counters leave the checker through output ports
// that a continuous assignment drives, and the parent prints the module
// variables that those ports drive.
// Neither simulator can run this test: Icarus Verilog 13.0 does not support
// checkers at all and Verilator 5.052 reports "Unsupported: checker rand".
// The expected output is the behavior that §16.5.1 defines.

`timescale 1ns/1ns

checker hist(logic clk, output int ticks_out, output int mismatches_out);
  rand bit v;
  global clocking gclk @(posedge clk); endclocking
  default clocking @(posedge clk); endclocking
  bit seen[$];
  bit saved_future;
  int ticks = 0, mismatches = 0;

  assign ticks_out = ticks;
  assign mismatches_out = mismatches;

  m1: assume property (v inside {0, 1});

  function bit save_future(bit fv);
    saved_future = fv;
    return 1'b1;
  endfunction

  ap: assert property (1'b1) begin
        if (seen.size() > 0 && $past(v) != seen[$]) mismatches++;
        seen.push_back(v);
        ticks++;
      end

  af: assert property (save_future($future_gclk(v))) begin
        if (saved_future != v) mismatches++;
      end
endchecker

module test_ch16_sim_checker_history;
  logic clk = 0;
  int ticks, mismatches;
  hist h1(clk, ticks, mismatches);

  always #5 clk = ~clk;

  initial begin
    #40;
    $display("ticks=%0d mismatches=%0d", ticks, mismatches);
    $finish;
  end
endmodule

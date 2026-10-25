/*
:name: test_nba_order_across_blocks_determinate
:description: two nonblocking assignments in different procedures that update the same variable in the same later time step take effect in the order in which they were executed, so the one executed later wins, whatever the order of the procedures in the source (IEEE 1800-2023 Section 10.4.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2 4.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nba_order_across_blocks_determinate.expected
*/
// IEEE 1800-2023 §10.4.2: that two nonblocking assignments to a variable
// are in different procedures does not by itself make the order of their
// updates indeterminate. When one of them is clearly executed before the
// other, their updates happen in that order (4.6), even if both are due in
// the same time step.
//
// For a, the procedure written first executes "a <= #3 9" at time 7, and
// the one written second executes "a <= #8 5" at time 2; both updates are
// due at time 10, and the one executed at 7 comes last: a is 9. For b the
// times are swapped (the one written first runs at 2), and b ends as 4.
// The values are printed at time 11.
//
// The 5.052 release of Verilator ends with a = 5, applying the updates of a
// in the order of the procedures in the source rather than the order in
// which they were executed.

`timescale 1ns/1ns
module test_nba_order_across_blocks_determinate;
  int a = 0, b = 0;

  initial #7 a <= #3 9;
  initial #2 a <= #8 5;

  initial #2 b <= #8 7;
  initial #7 b <= #3 4;

  initial #11 $display("t=11: a=%0d b=%0d", a, b);
endmodule

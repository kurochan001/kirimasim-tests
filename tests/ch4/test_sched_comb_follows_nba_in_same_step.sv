/*
:name: test_sched_comb_follows_nba_in_same_step
:description: An always_comb procedure that reads a flop output has followed its nonblocking update by the end of the time step of the edge (IEEE 1800-2023 Section 4.4.2.4)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.4 4.4.2.9 9.2.2.2 21.2.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_comb_follows_nba_in_same_step.expected
*/
// IEEE 1800-2023 §9.2.2.2: always_comb runs again whenever a variable it reads
// changes, so after the NBA region (§4.4.2.4) updates q at a rising edge, it
// gives y = 2 * q in the same time step. $strobe at the edge (§21.2.2) prints
// in the Postponed region (§4.4.2.9), when both have their new values.

`timescale 1ns/1ns

module test_sched_comb_follows_nba_in_same_step;
  bit clk = 0;
  int q = 1, y;

  always #5 clk = ~clk;
  always_ff @(posedge clk) q <= q + 1;
  always_comb y = 2 * q;

  initial begin
    repeat (3) begin
      @(posedge clk);
      $strobe("%0t: q=%0d y=%0d", $time, q, y);
    end
    #1 $finish;
  end
endmodule

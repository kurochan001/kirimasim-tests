/*
:name: test_clocking_output_skew_zero
:description: An output skew of zero drives the clocking output in the time step of the clocking event, and a skew of two time units drives it two units later (IEEE 1800-2023 Section 14.4)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.4 14.16 14.16.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_output_skew_zero.expected
*/
// IEEE 1800-2023 §14.4: an output skew gives the number of time units after
// the clocking event at which a drive of the clockvar changes its signal.
// §14.16: a drive matures in the Re-NBA region of that time step, so a
// process that reads the signal in the same time step still sees the old
// value. §14.16.1: the drive is made at the clocking event at which the
// statement runs. The clock rises at 5 and 15; a is driven with skew #0 and
// b with skew #2, so a changes at 5 and 15 and b at 7 and 17.

`timescale 1ns/1ns

module test_clocking_output_skew_zero;
  logic clk = 0;
  logic a = 0;
  logic b = 0;

  always #5 clk = ~clk;   // posedges at 5, 15

  clocking cb @(posedge clk);
    output #0 a;
    output #2 b;
  endclocking

  initial begin
    @(cb);
    cb.a <= 1;
    cb.b <= 1;
    $display("%0d: a=%b b=%b", $time, a, b);
    #1 $display("%0d: a=%b b=%b", $time, a, b);
    #2 $display("%0d: a=%b b=%b", $time, a, b);
    @(cb);
    cb.a <= 0;
    cb.b <= 0;
    #1 $display("%0d: a=%b b=%b", $time, a, b);
    #2 $display("%0d: a=%b b=%b", $time, a, b);
    $finish;
  end
endmodule

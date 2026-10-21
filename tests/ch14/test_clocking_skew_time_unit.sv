/*
:name: test_clocking_skew_time_unit
:description: Input and output skews are counted in the time unit of the clocking block's scope, here 10ns, not in nanoseconds (IEEE 1800-2023 Sections 14.4, 3.14.2.2)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.4 3.14.2.2 14.13 14.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_skew_time_unit.expected
*/
// IEEE 1800-2023 §14.4: a skew is a time value in the time unit of the scope
// that declares the clocking block. §3.14.2.2: timeunit and timeprecision set
// that unit and precision, here 10ns and 1ns, so the input skew #1 is 10ns
// and the output skew #2 is 20ns. §14.13, §14.16: the input is sampled at
// the event minus its skew and a drive matures at the event plus its skew.
// The clock rises at 50ns and at 150ns; d changes at 45ns and at 135ns, so
// the edges sample 0 and 2. The drive at 50ns changes q at 70ns. $realtime
// reports the times in units of 10ns, 5.0 and so on.

`timescale 1ns/1ns

module test_clocking_skew_time_unit;
  timeunit 10ns;
  timeprecision 1ns;

  logic clk = 0;
  logic q = 0;
  logic [3:0] d = 0;

  always #5 clk = ~clk;   // posedges at 50ns, 150ns

  clocking cb @(posedge clk);
    input #1 d;
    output #2 q;
  endclocking

  initial begin
    #4.5 d = 1;           // 45ns, after the sample point at 40ns
    @(cb);                // 50ns
    $display("%0.1f: d=%0d", $realtime, cb.d);
    cb.q <= 1;
    #0.2 $display("%0.1f: q=%b", $realtime, q);
    #1.9 $display("%0.1f: q=%b", $realtime, q);
    #6.4 d = 2;           // 135ns, before the sample point at 140ns
    @(cb);                // 150ns
    $display("%0.1f: d=%0d", $realtime, cb.d);
    $finish;
  end
endmodule

/*
:name: test_clocking_default_skew
:description: A default input or output skew applies to every clockvar that does not give its own (IEEE 1800-2023 Section 14.4)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.4 14.13 14.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_default_skew.expected
*/
// IEEE 1800-2023 §14.4: the default input skew of a clocking block applies to
// the clockvars that do not give a skew, and so does the default output skew.
// Here they are #2 and #3. The input d is set at 4, after the sample point at
// 3 of the edge at 5, so cb.d at 5 is the old 0; it is set to 0 at 14, after
// the sample point at 13 of the edge at 15, so cb.d at 15 is the old 1. §14.16:
// a synchronous drive matures its output skew after the clocking event, so the
// drives given at 5 and 15 change q at 8 and 18. §14.13: the sampled values
// are updated before the process waiting on the clocking event resumes.
// The Active observations at 8 and 18 precede the Re-NBA output updates;
// the Postponed $strobe observations see the new values. Finish at 19 so the
// final time slot completes. The 5.052 release of Verilator updates q before
// the Active observations; it is not an oracle for this region ordering.

`timescale 1ns/1ns

module test_clocking_default_skew;
  logic clk = 0;
  logic d = 0;
  logic q = 0;

  always #5 clk = ~clk;

  clocking cb @(posedge clk);
    default input #2 output #3;
    input d;
    output q;
  endclocking

  initial begin
    #4 d = 1;
    @(cb);
    $display("%0d: d=%b", $time, cb.d);
    cb.q <= 1;
    #1 $display("%0d: q=%b", $time, q);
    #2 $display("%0d: q=%b", $time, q);
    $strobe("%0d end: q=%b", $time, q);
    #6 d = 0;
    @(cb);
    $display("%0d: d=%b", $time, cb.d);
    cb.q <= 0;
    #1 $display("%0d: q=%b", $time, q);
    #2 $display("%0d: q=%b", $time, q);
    $strobe("%0d end: q=%b", $time, q);
    #1 $finish;
  end
endmodule

/*
:name: test_expect_vacuous_and_nonblocking
:description: an expect statement whose implication succeeds vacuously at its first tick unblocks there, the statements after an expect see the nonblocking updates of the tick where the property completed, and expect statements in forked processes complete independently (IEEE 1800-2023 Section 16.17)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.17 16.12.7 4.4.2 9.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expect_vacuous_and_nonblocking.expected
*/
// IEEE 1800-2023 §16.17: expect starts one evaluation of its property at the
// next tick of its clock after it is executed and blocks until the property
// succeeds or fails; the pass or fail statement and then the next statement
// run after the Observed region of the time step where it completes, so
// after the NBA region (§4.4.2), where q has taken its value of that tick. q
// counts the ticks with a nonblocking assignment, so it is n at the n-th
// tick, 5 + 10 * (n - 1). The first expect is executed at 2; a is low at 5,
// so a |=> b succeeds vacuously there (§16.12.7). The fork (§9.3.2) then
// starts two expects at 5, which begin at 15: ##2 b passes at 35 with b,
// while c ##1 c fails at 25, as c is high at 15 only.

`timescale 1ns/1ns

module test_expect_vacuous_and_nonblocking;
  logic clk = 0, a = 0, b = 0, c = 0;
  int q = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  always @(posedge clk) q <= q + 1;

  initial begin
    #10 c = 1;    // sampled at 15
    #10 c = 0;
    #10 b = 1;    // sampled at 35
    #10 b = 0;
  end

  initial begin
    #2;
    expect (@(posedge clk) a |=> b) $display("%0d: a |=> b passed, q=%0d", $time, q);
    else $display("%0d: a |=> b failed, q=%0d", $time, q);
    $display("%0d: after the first expect, q=%0d", $time, q);
    fork
      begin
        expect (@(posedge clk) ##2 b) $display("%0d: ##2 b passed, q=%0d", $time, q);
        else $display("%0d: ##2 b failed, q=%0d", $time, q);
      end
      begin
        expect (@(posedge clk) c ##1 c) $display("%0d: c ##1 c passed, q=%0d", $time, q);
        else $display("%0d: c ##1 c failed, q=%0d", $time, q);
      end
    join
    $display("%0d: after the join, q=%0d", $time, q);
    $finish;
  end
endmodule

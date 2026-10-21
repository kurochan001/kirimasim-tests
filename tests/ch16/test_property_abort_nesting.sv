/*
:name: test_property_abort_nesting
:description: an abort condition that becomes true in the time step where the property would end takes precedence over its result, of two nested abort operators whose conditions become true in the same time step the outer one decides, and not inverts the effect of accept_on (IEEE 1800-2023 Section 16.12.14)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.14 16.12.3 16.5.1 16.12.7 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_abort_nesting.expected
*/
// IEEE 1800-2023 §16.12.14: accept_on (c) p is true, and reject_on (c) p false,
// if c becomes true during the evaluation of p, also in the time step where p
// ends; c uses sampled values (§16.5.1). Nested abort operators are applied
// from the outside in: if both conditions become true in the same time step,
// the outer one decides; if one becomes true first, it decides. not (accept_on
// (c) p) is false when c aborts p (§16.12.3). Each assertion checks start |->
// ... ##2 done (§16.12.7), so an evaluation runs from the tick T with start to
// T+2. stop, ka and kr are high just before and after the tick named, so their
// sampled values first become true at that tick. The fail actions count the
// failures of each phase (§16.14.1). Verilator 5.052 passes a_not in the third
// and the fifth phases, where ka aborts the evaluation at T+1; there not
// (accept_on (ka) ##2 done) has to fail.

`timescale 1ns/1ns

module test_property_abort_nesting;
  logic clk = 0, start = 0, done = 0, stop = 0, ka = 0, kr = 0;
  int f_rej = 0, f_acc = 0, f_ar = 0, f_ra = 0, f_not = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_rej: assert property (@(posedge clk) start |-> reject_on (stop) ##2 done) else f_rej++;
  a_acc: assert property (@(posedge clk) start |-> accept_on (stop) ##2 done) else f_acc++;
  a_ar: assert property (@(posedge clk) start |-> accept_on (ka) reject_on (kr) ##2 done)
    else f_ar++;
  a_ra: assert property (@(posedge clk) start |-> reject_on (kr) accept_on (ka) ##2 done)
    else f_ra++;
  a_not: assert property (@(posedge clk) start |-> not (accept_on (ka) ##2 done)) else f_not++;

  // Runs one phase of four ticks, T at 5 after its start, changing the inputs
  // at every time unit. done is d at T+2; stop, ka and kr are high at the
  // tick given (1 for T+1, 2 for T+2; 0 for none) and one time unit before.
  task automatic phase(string name, logic d, int t_stop, int t_ka, int t_kr);
    for (int s = 0; s < 40; s++) begin
      start = s < 10;
      done = d && s >= 20 && s < 30;
      stop = t_stop != 0 && (s == 10 * t_stop + 4 || s == 10 * t_stop + 5);
      ka = t_ka != 0 && (s == 10 * t_ka + 4 || s == 10 * t_ka + 5);
      kr = t_kr != 0 && (s == 10 * t_kr + 4 || s == 10 * t_kr + 5);
      #1;
    end
    $display("%s: a_rej %0d, a_acc %0d, a_ar %0d, a_ra %0d, a_not %0d", name, f_rej, f_acc, f_ar,
             f_ra, f_not);
    f_rej = 0;
    f_acc = 0;
    f_ar = 0;
    f_ra = 0;
    f_not = 0;
  endtask

  initial begin
    phase("stop at T+2, done", 1, 2, 0, 0);
    phase("stop at T+2, no done", 0, 2, 0, 0);
    phase("ka and kr at T+1, done", 1, 0, 1, 1);
    phase("kr at T+1, ka at T+2, done", 1, 0, 2, 1);
    phase("ka at T+1, kr at T+2, done", 1, 0, 1, 2);
    $finish;
  end
endmodule

/*
:name: test_abort_nested_sync_forms
:description: synchronous and asynchronous abort operators can be nested in any order; they are applied from the outside in, so when two conditions become true in the same time step the outer operator decides, and a condition that comes after the inner operator has ended its operand has no effect (IEEE 1800-2023 Section 16.12.14)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.14 16.5.1 16.12.7 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_abort_nested_sync_forms.expected
*/
// IEEE 1800-2023 §16.12.14: any nesting of accept_on, reject_on,
// sync_accept_on and sync_reject_on is allowed. Nested abort operators are
// evaluated in lexical order, so if the conditions of two of them become
// true in the same time step the outer one takes precedence; an inner abort
// ends the evaluation of the operand of the outer operator. The synchronous
// forms see their condition, by its sampled value (§16.5.1), only at clock
// ticks, the asynchronous ones in every time step. Each assertion checks
// start |-> (...) ##2 done (§16.12.7) from tick 0 of a phase, at T; ticks
// are at T, T+10 and T+20, and done is sampled high at tick 2 except in the
// third phase. "at tick n" means a condition that is set at the falling edge
// before tick n and cleared at the one after; "between ticks" means ka high
// from T+2 to T+4 only. The fail actions (§16.14.1) count the failures of a
// phase: n1 is sync_accept_on (ka) sync_reject_on (kr), n2 the same pair in
// the other order, n3 accept_on (ka) outside sync_reject_on (kr), and n4
// sync_reject_on (kr) outside accept_on (ka).

`timescale 1ns/1ns

module test_abort_nested_sync_forms;
  logic clk = 0, start = 0, done = 0, ka = 0, kr = 0;
  int f1 = 0, f2 = 0, f3 = 0, f4 = 0;

  n1: assert property (@(posedge clk) start |-> sync_accept_on (ka) sync_reject_on (kr) ##2 done)
    else f1++;
  n2: assert property (@(posedge clk) start |-> sync_reject_on (kr) sync_accept_on (ka) ##2 done)
    else f2++;
  n3: assert property (@(posedge clk) start |-> accept_on (ka) sync_reject_on (kr) ##2 done)
    else f3++;
  n4: assert property (@(posedge clk) start |-> sync_reject_on (kr) accept_on (ka) ##2 done)
    else f4++;

  // Runs one phase, from T-5 to T+35. ka_at and kr_at give the tick at which
  // each condition is sampled high (0 for never); ka_between pulses ka
  // between tick 0 and tick 1.
  task automatic phase(string name, bit with_done, int ka_at, int kr_at, bit ka_between);
    start = 1;
    for (int t = 0; t < 4; t++) begin
      #5 clk = 1;                        // tick t at T + 10t
      if (t == 0 && ka_between) begin
        #2 ka = 1;
        #2 ka = 0;
        #1 clk = 0;
      end else begin
        #5 clk = 0;
      end
      start = 0;
      ka = (t + 1 == ka_at);
      kr = (t + 1 == kr_at);
      done = with_done && (t + 1 == 2);
    end
    $display("%s: n1 %0d, n2 %0d, n3 %0d, n4 %0d", name, f1, f2, f3, f4);
    f1 = 0;
    f2 = 0;
    f3 = 0;
    f4 = 0;
  endtask

  initial begin
    phase("ka and kr at tick 1", 1, 1, 1, 0);
    phase("kr at tick 1, ka at tick 2", 1, 2, 1, 0);
    phase("ka at tick 1, kr at tick 2, no done", 0, 1, 2, 0);
    phase("ka between ticks, kr at tick 1", 1, 0, 1, 1);
    $finish;
  end
endmodule

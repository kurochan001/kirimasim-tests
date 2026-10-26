/*
:name: test_sva_satisfaction_fail_strong
:description: A completed nonempty match of a sequence property holds strongly, while a tick where the first element is false is a bad state after which no extension can satisfy the property, so it fails; the pass and fail actions record the tick of each (IEEE 1800-2023 Section 16.12.21)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.21 16.12.2 16.14.1 16.14.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sva_satisfaction_fail_strong.expected
*/
// IEEE 1800-2023 Section 16.12.21: on a finite behavior a property holds
// strongly when no bad state has been seen, all future obligations are met,
// and it holds on every extension. A nonempty match of go ##1 (a ##1 b)
// completed at a tick has met every obligation, and no extension can undo the
// match, so it holds strongly; its pass action runs at that tick. A tick where
// the first element a is false is a bad state, and no extension can satisfy
// that attempt, so it fails; its fail action runs at that tick.
//
// go is high only at the tick 5 and go2 only at the tick 25. a is high at 5
// and b at 15, so the first assertion completes its match at 15. a2 is 0 at
// 25, so go2 |-> (a2 ##1 b2) sees its bad state at 25. $assertvacuousoff
// keeps the vacuous successes of the attempts with go and go2 low out of the
// pass queue. The queues are printed at 26, in a fixed order.

`timescale 1ns/1ns

module test_sva_satisfaction_fail_strong;
  logic clk = 0, go = 0, go2 = 0, a = 0, b = 0, a2 = 0, b2 = 0;
  int ph[$], fh[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25

  a_holds: assert property (@(posedge clk) go |-> (a ##1 b))
    ph.push_back(int'($time)); else fh.push_back(int'($time));
  a_fails: assert property (@(posedge clk) go2 |-> (a2 ##1 b2))
    ph.push_back(int'($time)); else fh.push_back(int'($time));

  initial begin
    $assertvacuousoff;
    #2 begin
      go = 1;                   // the tick 5
      a = 1;
    end
    @(negedge clk) begin        // the tick 15
      go = 0;
      b = 1;
    end
    @(negedge clk) go2 = 1;     // the tick 25
    #6;
    $write("pass:"); foreach (ph[i]) $write(" %0d", ph[i]); $write("\n");
    $write("fail:"); foreach (fh[i]) $write(" %0d", fh[i]); $write("\n");
    $finish;
  end
endmodule

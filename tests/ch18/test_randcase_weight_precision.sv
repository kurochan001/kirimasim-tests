/*
:name: test_randcase_weight_precision
:description: A randcase weight has the width of its own expression, so an 8-bit sum that wraps to 0 is never taken, randcase takes no branch when all weights are 0, weights are evaluated each time, and each weight expression at most once per execution (IEEE 1800-2023 Section 18.16)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randcase_weight_precision.expected
*/
// IEEE 1800-2023 §18.16: each weight of randcase is evaluated with its
// self-determined width, and a branch of weight 0 is never taken. a + b of
// two 8-bit variables holding 200 and 56 is 256, which is 0 in 8 bits, so
// that branch is never taken and the other one always is. When all weights
// are 0 no branch is taken (a tool may warn) and the statement after
// randcase runs. The weights are expressions evaluated each time randcase
// runs, so weights that depend on i, one of them 1 and the others 0, select
// a fixed branch in each iteration of the loop. A weight expression is
// evaluated at most once each time randcase runs; wt() counts its calls.
// In Verilator 5.052, wt() is called twice each time randcase runs.

module test_randcase_weight_precision;
  bit [7:0] a = 8'd200, b = 8'd56;
  int wrapped = 0, other = 0, none = 0, after = 0, multi = 0;
  int evals;
  string seq = "";

  function int wt();
    evals++;
    return 2;
  endfunction

  initial begin
    repeat (100) begin
      randcase
        a + b : wrapped++;
        1     : other++;
      endcase
    end
    $display("8-bit weight a + b: taken %0d times, weight 1 taken %0d times", wrapped, other);
    repeat (10) begin
      randcase
        0     : none++;
        a + b : none++;
      endcase
      after++;
    end
    $display("all weights 0: branches taken %0d, statement after it ran %0d times", none, after);
    for (int i = 0; i < 6; i++) begin
      randcase
        i % 3 == 0 : seq = {seq, "A"};
        i % 3 == 1 : seq = {seq, "B"};
        i % 3 == 2 : seq = {seq, "C"};
      endcase
    end
    $display("weights that follow i: %s", seq);
    repeat (20) begin
      evals = 0;
      randcase
        wt() : other++;
        1    : other++;
      endcase
      if (evals > 1) multi++;
    end
    $display("weight evaluated more than once: %0d times", multi);
  end
endmodule

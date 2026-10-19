/*
:name: test_randcase_zero_weight
:description: randcase never takes a branch whose weight is zero, also when the weight is an expression (IEEE 1800-2023 Section 18.16)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randcase_zero_weight.expected
*/
// IEEE 1800-2023 §18.16: randcase takes one of its branches at random, each with
// a probability proportional to its weight. A branch whose weight is zero is
// never taken. Weights can be expressions.

module test_randcase_zero_weight;
  int n0, n1, n2;
  int w = 0;

  initial begin
    repeat (200) begin
      randcase
        0: n0++;
        3: n1++;
        1: n2++;
        w: n0++;
      endcase
    end
    $display("zero-weight branches taken: %0d, other branches taken: %0d", n0, n1 + n2);
  end
endmodule

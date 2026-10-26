/*
:name: test_solve_before_probability
:description: Without solve before every legal combination of s and d is equally likely, and solve s before d changes the probability of s but not the set of legal combinations or the success of the call (IEEE 1800-2023 Section 18.5.9)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.9 18.5.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_solve_before_probability.expected
*/
// IEEE 1800-2023 §18.5.9: the solver gives every legal value combination the
// same probability, and solve s before d changes only the probabilities, not
// the solution space and not the success of randomize(). The constraint
// s -> d == 0 leaves five combinations: (1,0) and (0,0) to (0,3). Without an
// order each has probability 1/5, so s is 1 in about a fifth of 800 calls;
// with solve s before d, s is chosen first and is 1 in about half of them.
// The test also checks that every one of the five combinations occurs
// equally often and that no call fails.
// In Verilator 5.052 the order does not change the distribution, so s stays
// at about a fifth of the calls with and without solve before.

class sb_free;
  rand bit s;
  rand bit [1:0] d;
  constraint c { s -> d == 0; }
endclass

class sb_ordered;
  rand bit s;
  rand bit [1:0] d;
  constraint c { s -> d == 0; solve s before d; }
endclass

module test_solve_before_probability;
  sb_free of = new;
  sb_ordered oo = new;
  int n[8];
  int on[8];
  int free_fail, ordered_fail;
  int free_bad, ordered_bad;
  int in_range;

  initial begin
    foreach (n[i]) n[i] = 0;
    free_fail = 0;
    repeat (800) begin
      if (!of.randomize()) free_fail++;
      else n[{of.s, of.d}]++;
    end
    free_bad = n[5] + n[6] + n[7];
    in_range = 1;
    for (int i = 0; i < 5; i++)
      if (n[i] < 100 || n[i] > 220) in_range = 0;
    $display("unordered: failures %0d, illegal %0d, s==1 in 100..220 %0d",
             free_fail, free_bad, n[4] >= 100 && n[4] <= 220);
    $display("five combinations each in 100..220 %0d", in_range);
    foreach (on[i]) on[i] = 0;
    ordered_fail = 0;
    repeat (800) begin
      if (!oo.randomize()) ordered_fail++;
      else on[{oo.s, oo.d}]++;
    end
    ordered_bad = on[5] + on[6] + on[7];
    $display("ordered: failures %0d, illegal %0d, s==1 in 340..460 %0d",
             ordered_fail, ordered_bad, on[4] >= 340 && on[4] <= 460);
  end
endmodule

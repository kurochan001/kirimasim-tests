/*
:name: test_randc_solved_first_distribution
:description: A randc variable is solved before the rand variables of the same object, so its values stay equally likely although they allow different numbers of solutions for a rand variable (IEEE 1800-2023 Section 18.4.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randc_solved_first_distribution.expected
*/
// IEEE 1800-2023 §18.4.2: randc variables are solved before other random
// variables, so c is drawn from a permutation of 0 to 3 without regard to
// the constraint c < r. The values 0, 1 and 2 leave 3, 2 and 1 values for r,
// so a solver that solved c and r together would make c == 2 rarer; with the
// required order the three values of c are equally likely. The test collects
// 900 results that satisfy c < r and compares how often c is 0 and 2.
// A call in which the permutation reaches 3 cannot be solved; the test does
// not count such calls, since skipping 3 and failing are both allowed.

class test_randc_solved_first_distribution_c;
  randc bit [1:0] c;
  rand bit [1:0] r;
  constraint c_order { c < r; }
endclass

module test_randc_solved_first_distribution;
  test_randc_solved_first_distribution_c o = new;
  int n[4];
  int ok = 0;
  int failed = 0;
  int violated = 0;

  initial begin
    repeat (1300) begin
      if (!o.randomize()) begin
        failed++;
      end else begin
        ok++;
        n[o.c]++;
        if (!(o.c < o.r)) violated++;
      end
    end
    $display("solutions: c<r always %0d, at least 100 %0d, c==0 at most 1.4 times c==2 %0d",
             violated == 0, n[0] + n[1] + n[2] >= 100, n[0] * 10 <= n[2] * 14);
    $display("c values above 2 in a solution %0d", n[3]);
  end
endmodule

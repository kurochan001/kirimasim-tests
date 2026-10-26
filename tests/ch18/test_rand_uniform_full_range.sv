/*
:name: test_rand_uniform_full_range
:description: An unconstrained rand variable takes every value of its range with equal probability, and a set constraint keeps the remaining values equally likely (IEEE 1800-2023 Section 18.4.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.4.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_rand_uniform_full_range.expected
*/
// IEEE 1800-2023 §18.4.1: an unconstrained rand variable is uniformly
// distributed over its range, so each of the 16 values of a 4-bit variable
// has probability 1/16. With a further set constraint the allowed values stay
// equally likely. 1600 calls give each nibble value about 100 results and
// each of the six allowed values of three about 267; the test checks that
// every value appears and that every count lies near its expected value, so
// a skewed or restricted generator changes the output.

class test_rand_uniform_full_range_c;
  rand bit [3:0] nib;
  rand bit [2:0] three;
  constraint c_three { three inside {[1:6]}; }
endclass

module test_rand_uniform_full_range;
  test_rand_uniform_full_range_c o = new;
  int n_nib[16];
  int n_three[8];
  int failed = 0;
  int out_of_set = 0;

  initial begin
    repeat (1600) begin
      if (!o.randomize()) failed++;
      n_nib[o.nib]++;
      n_three[o.three]++;
      if (o.three < 1 || o.three > 6) out_of_set++;
    end
    begin
      int seen = 0;
      int in_bounds = 1;
      foreach (n_nib[i]) begin
        if (n_nib[i] > 0) seen++;
        if (n_nib[i] < 40 || n_nib[i] > 260) in_bounds = 0;
      end
      $display("nibble: values seen %0d, counts in 40..260 %0d, outside range %0d",
               seen, in_bounds, out_of_set);
    end
    begin
      int seen = 0;
      int in_bounds = 1;
      foreach (n_three[i]) begin
        if (n_three[i] > 0) seen++;
        if (i >= 1 && i <= 6 && (n_three[i] < 160 || n_three[i] > 380))
          in_bounds = 0;
      end
      $display("three: values seen %0d, counts in 160..380 %0d, value 0 or 7 %0d",
               seen, in_bounds, n_three[0] + n_three[7]);
    end
    $display("failed calls %0d", failed);
  end
endmodule

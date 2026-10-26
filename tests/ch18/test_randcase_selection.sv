/*
:name: test_randcase_selection
:description: Each randcase branch is taken with probability weight over the sum, the selection uses one $urandom_range draw with lower values for earlier branches, and randcase choices are independent of thread order (IEEE 1800-2023 Section 18.16)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.16 18.14.2 18.13.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randcase_selection.expected
*/
// IEEE 1800-2023 §18.16: the weights 3, 1 and 4 of 8 give the branches the
// probabilities 0.375, 0.125 and 0.5; 800 runs put them near 300, 100 and 400.
// A randcase call retrieves one random number from the range 0 to the sum of
// the weights and gives the lower numbers to the earlier branches. For the
// weights 1 and 6 the sum is 7, so the first branch is taken exactly when
// $urandom_range(6) returns 0. The test seeds the process with 200 values,
// draws that number, seeds again and runs the randcase, and compares.
// Two workers seed themselves and run three choices with different delays;
// their results do not depend on the order in which they run.

module test_randcase_selection;
  int n1, n2, n3;
  int mismatches;
  int unsigned w1[4], w2[4], a[4], b[4];

  task automatic worker(output int unsigned q[4], input int seed, input int d);
    process p;
    p = process::self();
    p.srandom(seed);
    #(d);
    for (int i = 0; i < 4; i++) begin
      randcase
        1: q[i] = 1;
        1: q[i] = 2;
        1: q[i] = 3;
      endcase
    end
  endtask

  initial begin
    n1 = 0;
    n2 = 0;
    n3 = 0;
    repeat (800) begin
      randcase
        3: n1++;
        1: n2++;
        4: n3++;
      endcase
    end
    $display("weights 3:1:4: 300/100/400 ranges %0d %0d %0d",
             n1 >= 240 && n1 <= 360, n2 >= 60 && n2 <= 160, n3 >= 320 && n3 <= 480);
    mismatches = 0;
    for (int k = 1; k <= 200; k++) begin
      int unsigned x;
      int br;
      process::self().srandom(k);
      x = $urandom_range(6, 0);
      process::self().srandom(k);
      randcase
        1: br = 1;
        6: br = 2;
      endcase
      if ((br == 1) != (x == 0)) mismatches++;
    end
    $display("selection order: mismatches %0d", mismatches);
    fork
      worker(w1, 11, 0);
      worker(w2, 22, 0);
    join
    fork
      worker(a, 11, 3);
      worker(b, 22, 0);
    join
    $display("thread stability: worker 11 %0d, worker 22 %0d",
             w1 == a, w2 == b);
  end
endmodule

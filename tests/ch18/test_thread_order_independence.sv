/*
:name: test_thread_order_independence
:description: The values of $urandom, $urandom_range, shuffle, randcase, randsequence and std::randomize are independent of the order in which threads run, and a process seeded again repeats all of them (IEEE 1800-2023 Sections 18.14, 18.14.2 and 18.13.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.14 18.14.2 18.13.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_thread_order_independence.expected
*/
// IEEE 1800-2023 §18.14, §18.14.2: every thread has its own generator, so the
// values of $urandom, $urandom_range (18.13.2), shuffle, randcase, randsequence
// and std::randomize do not depend on when the threads run. Two workers seed
// themselves with 11 and 22 and then draw a value through each mechanism; the
// shuffle result is read from the first element of the shuffled array and the
// scope randomize fills the task-local z, which is copied to q[6]. The test
// runs the workers with the delays 0/0, 5/0 and 0/5 and compares each worker's
// results with its own first results. The same process seeded with 77 repeats
// a mixed sequence of five mechanisms.
// In Verilator 5.052 the value of std::randomize is not taken from the RNG of
// the calling process, so the two workers get different values for q[6].

module test_thread_order_independence;
  int unsigned w1[7], w2[7];
  int unsigned a[7], b[7];
  int unsigned s1[6], s2[6];

  task automatic worker(output int unsigned q[7], input int seed, input int d);
    process p;
    int arr[4];
    int unsigned z;
    p = process::self();
    p.srandom(seed);
    #(d);
    q[0] = $urandom;
    q[1] = $urandom_range(100);
    arr = '{1, 2, 3, 4};
    arr.shuffle();
    q[2] = arr[0];
    randcase
      1: q[3] = 1;
      1: q[3] = 2;
    endcase
    randsequence (main)
      main : x y;
      x : { q[4] = $urandom; };
      y : { q[5] = $urandom; };
    endsequence
    void'(std::randomize(z) with { z inside {[0:9]}; });
    q[6] = z;
  endtask

  task automatic mixed(output int unsigned q[6]);
    int arr[4];
    q[0] = $urandom;
    q[1] = $urandom_range(1000);
    arr = '{1, 2, 3, 4};
    arr.shuffle();
    q[2] = arr[0];
    randcase
      1: q[3] = 1;
      2: q[3] = 2;
    endcase
    randsequence (main)
      main : one two;
      one : { q[4] = 1; } | { q[4] = 2; };
      two : { q[5] = 3; } | { q[5] = 4; };
    endsequence
  endtask

  initial begin
    fork
      worker(w1, 11, 0);
      worker(w2, 22, 0);
    join
    fork
      worker(a, 11, 5);
      worker(b, 22, 0);
    join
    $display("same order: worker 11 %0d, worker 22 %0d",
             w1 == a, w2 == b);
    fork
      worker(a, 11, 0);
      worker(b, 22, 5);
    join
    $display("other order: worker 11 %0d, worker 22 %0d",
             w1 == a, w2 == b);
    process::self().srandom(77);
    mixed(s1);
    process::self().srandom(77);
    mixed(s2);
    $display("seeded process repeats every mechanism %0d", s1 == s2);
  end
endmodule

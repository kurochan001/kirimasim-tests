/*
:name: test_thread_stability_fork
:description: A forked thread gets its random generator from its parent when it is created, so its $urandom values do not depend on how many numbers a sibling thread draws (IEEE 1800-2023 Section 18.14.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.14.2 18.14.1 18.13.4 18.13.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_thread_stability_fork.expected
*/
// IEEE 1800-2023 §18.14.1, §18.14.2: each thread has its own generator, and a
// new thread is seeded with the next random value of its parent. The parent
// saves its state with get_randstate() (18.13.4) and forks threads a and b;
// a draws one number and b three. The parent then restores the state with
// set_randstate() (18.13.5) and forks them again, now with a drawing five
// numbers. Both times a and b get the same seeds, so b draws the same three
// numbers; what a draws does not matter.

module test_thread_stability_fork;
  int unsigned first[3], second[3];

  task automatic run(int a_draws, output int unsigned got[3]);
    fork
      begin : a
        int unsigned sink;
        repeat (a_draws) sink = $urandom;
      end
      begin : b
        for (int i = 0; i < 3; i++) got[i] = $urandom;
      end
    join
  endtask

  initial begin
    process self;
    string state;
    self = process::self();
    state = self.get_randstate();
    run(1, first);
    self.set_randstate(state);
    run(5, second);
    $display("b draws the same numbers: %0d", first == second);
  end
endmodule

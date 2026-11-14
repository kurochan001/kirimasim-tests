/*
:name: test_process_thread_kinds_and_final_process
:description: every instance of an initial procedure, each always, always_comb, always_latch and always_ff procedure, each parallel statement of fork-join, join_any and join_none and each dynamic process runs in its own thread, an always procedure keeps one thread over its repetitions, and the final procedures run from one process (IEEE 1800-2023 Section 9.5)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.5 9.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_process_thread_kinds_and_final_process.expected
*/
// IEEE 1800-2023 §9.5: a thread of execution is created for each initial
// procedure, each always, always_comb, always_latch and always_ff procedure,
// each parallel statement of a fork-join, fork-join_any or fork-join_none
// block, and each dynamic process. §9.2.3: final procedures do not run as
// processes of their own; they run as function calls from a single process.
// process::self() (§9.7) returns the handle of the calling thread.
//
// The test stores the handle that each thread sees: two initial procedures
// of the top module and the initial procedure of each of two instances of
// child, the four kinds of always procedure, the two branches of each kind
// of fork, three processes that a loop starts with fork-join_none and one
// that a function starts with fork-join_none. The 18 handles are all
// non-null and different. A tool that ran two of these in one thread, such
// as the procedures of the two instances or the branches of a fork and its
// parent, would print a smaller count.
//
// The general always procedure stores its handle again on each of its three
// runs and always_comb on each of its two runs; the handles of one procedure
// are the same, so each repetition is the same thread, not a new one.
//
// Each final procedure stores its handle and, if the other one has already
// run, prints whether the two are equal. Only the one that runs second
// prints, and the line is the same whichever order the tool chooses. A tool
// that gave each final procedure a process of its own would print 0.
//
// Icarus Verilog 13.0 does not support the process class (a syntax error).
// The 5.054 release of Verilator returns one handle for the initial
// procedure that stores p_init_b, the initial procedures of both instances
// and the always_latch procedure (15 distinct threads), and a new handle on the
// second run of always_comb (0); its final procedures match. The expected
// output follows the standard.

`timescale 1ns/1ns

module child;
  process p;
  initial p = process::self();
endmodule

module test_process_thread_kinds_and_final_process;
  logic clk = 0, latch_en = 1;
  int comb_sel = 0;
  int n_always = 0;
  process p_init_a, p_init_b, p_latch, p_ff, p_func, p_final_a, p_final_b;
  process p_always[3];
  process p_comb[2];
  process p_join[2], p_any[2], p_none[2], p_dyn[3];

  child u1();
  child u2();

  function automatic int distinct(process ps[$]);
    int n = 0;
    foreach (ps[i]) begin
      bit seen = 0;
      for (int j = 0; j < i; j++)
        if (ps[j] == ps[i]) seen = 1;
      if (!seen && ps[i] != null) n++;
    end
    return n;
  endfunction

  function void spawn();
    fork
      p_func = process::self();
    join_none
  endfunction

  always begin
    if (n_always < 3) begin
      p_always[n_always] = process::self();
      n_always++;
    end
    @(posedge clk);
  end

  always_comb p_comb[comb_sel] = process::self();

  always_latch if (latch_en) p_latch = process::self();

  always_ff @(posedge clk) p_ff = process::self();

  initial p_init_b = process::self();

  initial begin
    p_init_a = process::self();
    fork
      p_join[0] = process::self();
      p_join[1] = process::self();
    join
    fork
      p_any[0] = process::self();
      #1 p_any[1] = process::self();
    join_any
    fork
      p_none[0] = process::self();
      p_none[1] = process::self();
    join_none
    for (int k = 0; k < 3; k++)
      fork
        automatic int kk = k;
        p_dyn[kk] = process::self();
      join_none
    spawn();
    #2 comb_sel = 1;
    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1 $display("distinct threads: %0d of 18",
                distinct('{p_init_a, p_init_b, u1.p, u2.p, p_always[0], p_comb[0], p_latch,
                           p_ff, p_join[0], p_join[1], p_any[0], p_any[1], p_none[0],
                           p_none[1], p_dyn[0], p_dyn[1], p_dyn[2], p_func}));
    $display("always runs %0d, one thread: %0d", n_always,
             p_always[0] == p_always[1] && p_always[1] == p_always[2]);
    $display("always_comb one thread over two runs: %0d",
             p_comb[0] != null && p_comb[0] == p_comb[1]);
    $finish;
  end

  final begin
    p_final_a = process::self();
    if (p_final_b != null)
      $display("final procedures: non-null %0d, one process %0d",
               p_final_a != null, p_final_a == p_final_b);
  end

  final begin
    p_final_b = process::self();
    if (p_final_a != null)
      $display("final procedures: non-null %0d, one process %0d",
               p_final_b != null, p_final_a == p_final_b);
  end
endmodule

/*
:name: test_process_threads_distinct
:description: Each initial, always and final procedure, each parallel statement of a fork and each process started by fork-join_none runs as a thread of its own (IEEE 1800-2023 Section 9.5)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.5 9.7 9.3.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_process_threads_distinct.expected
*/
// IEEE 1800-2023 §9.5: a thread of execution is created for each initial,
// final and always procedure, for each parallel statement of a fork and for
// each dynamic process. process::self() (9.7) gives each of them a different
// handle. The always procedure waits forever, so it is still waiting when
// the final procedure runs; the threads of the first fork have finished then.

module test_process_threads_distinct;
  process p_initial, p_always, p_first, p_second, p_dynamic, p_final;

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

  always begin
    p_always = process::self();
    wait (1'b0);
  end

  initial begin
    p_initial = process::self();
    fork
      p_first = process::self();
      p_second = process::self();
    join
    fork
      p_dynamic = process::self();
    join_none
    #1 $display("distinct threads: %0d", distinct('{p_initial, p_always, p_first, p_second,
                                                    p_dynamic}));
  end

  final begin
    p_final = process::self();
    $display("with the final procedure: %0d", distinct('{p_initial, p_always, p_first,
                                                          p_second, p_dynamic, p_final}));
    $display("always waiting: %0d, fork branch finished: %0d",
             p_always.status() == process::WAITING, p_first.status() == process::FINISHED);
  end
endmodule

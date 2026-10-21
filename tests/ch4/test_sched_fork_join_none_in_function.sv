/*
:name: test_sched_fork_join_none_in_function
:description: A function can spawn a process with fork-join_none, which starts after the calling process blocks, and the function returns without waiting (IEEE 1800-2023 Section 4.4.2.2)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.2 13.4.4 9.3.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_fork_join_none_in_function.expected
*/
// IEEE 1800-2023 §13.4.4: fork-join_none is allowed in a function, since it
// does not block, when the function is called from a procedure such as initial.
// §9.3.2: the spawned process starts only when the calling process blocks or
// ends, so the caller prints first; the spawned process then waits for its
// delay.
// Icarus Verilog 13.0 rejects the delay in the spawned process
// (docs/simulator-differences.md).

`timescale 1ns/1ns

module test_sched_fork_join_none_in_function;
  function void spawn(int id);
    fork
      begin
        $display("spawned %0d starts at %0t", id, $time);
        #1 $display("spawned %0d ends at %0t", id, $time);
      end
    join_none
  endfunction

  initial begin
    spawn(1);
    $display("returned at %0t", $time);
    #5 $display("caller at %0t", $time);
  end
endmodule

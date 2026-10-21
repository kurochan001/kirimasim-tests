/*
:name: test_sched_join_any_resumes_after_first_child
:description: fork-join_any resumes its parent when the first child ends, and the other children go on (IEEE 1800-2023 Section 4.4.2.2)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.2 9.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_join_any_resumes_after_first_child.expected
*/
// IEEE 1800-2023 §9.3.2: with join_any the parent waits until any one of the
// processes it spawned ends, then goes on while the others keep running. The
// child with the shorter delay ends at 1, after its display, and the parent
// goes on at 1; the other child prints at 2.

`timescale 1ns/1ns

module test_sched_join_any_resumes_after_first_child;
  initial begin
    fork
      #2 $display("slow child at %0t", $time);
      #1 $display("fast child at %0t", $time);
    join_any
    $display("parent at %0t", $time);
  end
endmodule

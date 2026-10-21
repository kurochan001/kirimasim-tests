/*
:name: test_sched_join_none_children_wait_for_blocking_parent
:description: Processes spawned by fork-join_none start only when their parent blocks, so the parent's statements before its first delay all come first (IEEE 1800-2023 Section 4.4.2.2)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.2 9.3.2 4.7
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_join_none_children_wait_for_blocking_parent.expected
*/
// IEEE 1800-2023 §9.3.2: the processes spawned by fork-join_none do not start
// until the parent executes a blocking statement or ends, so both of the
// parent's lines before its delay come before the child's line. The child
// starts when the parent reaches #1, and the parent's last line comes after the
// delay.

`timescale 1ns/1ns

module test_sched_join_none_children_wait_for_blocking_parent;
  int x = 0;
  initial begin
    fork
      $display("child sees x=%0d", x);
    join_none
    x = 1;
    $display("parent wrote x=%0d", x);
    x = 2;
    $display("parent wrote x=%0d", x);
    #1 $display("parent after its delay at %0t", $time);
  end
endmodule

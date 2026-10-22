/*
:name: test_unbounded_queue_tail_after_resize
:description: The dollar queue index tracks the new last element after pushes and pops (IEEE 1800-2023 Section 6.20.7)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unbounded_queue_tail_after_resize.expected
*/
// IEEE 1800-2023 6.20.7: The dollar symbol in a queue selection is evaluated
// from the current queue size, including in a slice ending at the last element.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

module test_unbounded_queue_tail_after_resize;
  int q[$] = '{2, 4};
  int tail[$];
  int removed;
  initial begin
    q.push_back(9); tail = q[1:$];
    $display("pushed_last=%0d slice=%0d,%0d", q[$], tail[0], tail[1]);
    removed = q.pop_back();
    $display("popped=%0d new_last=%0d", removed, q[$]);
  end
endmodule

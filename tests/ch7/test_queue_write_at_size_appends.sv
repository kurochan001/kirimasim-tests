/*
:name: test_queue_write_at_size_appends
:description: Writing a queue element at index size() appends it, and writing beyond that does nothing (IEEE 1800-2023 Section 7.10.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.1 7.4.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_write_at_size_appends.expected
*/
// IEEE 1800-2023 §7.4.5: writing an array with an invalid index does nothing,
// except for element [$+1] of a queue, one past its last element, where the
// write adds the element (7.10.1). So q[q.size()] = v appends v, and a loop
// can build a queue element by element from index 0. A write two or more
// past the end is invalid and leaves the queue as it was.

module test_queue_write_at_size_appends;
  int q[$] = {1, 2, 3};
  int p[$];

  initial begin
    q[3] = 99;
    $display("after q[3] = 99: size %0d, q[3] = %0d", q.size(), q[3]);
    q[5] = 7;
    $display("after q[5] = 7: size %0d", q.size());
    for (int i = 0; i < 4; i++) p[i] = i * 10;
    $display("p: size %0d, %0d %0d %0d %0d", p.size(), p[0], p[1], p[2], p[3]);
  end
endmodule

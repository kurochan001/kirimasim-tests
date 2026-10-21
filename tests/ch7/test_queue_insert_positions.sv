/*
:name: test_queue_insert_positions
:description: insert(index, item) puts an item at the first, middle or end position of a queue and shifts the later elements, and an index equal to the size appends, for queues of int and string (IEEE 1800-2023 Section 7.10.2.2)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.2.2 7.10.2.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_insert_positions.expected
*/
// IEEE 1800-2023 §7.10.2.2: insert(index, item) puts item at index and moves
// the elements from index on one position later; an index equal to the size
// adds the item at the end. The test inserts into an empty int queue at 0,
// into the middle and at the end, and then after a delete, and it inserts into
// an empty string queue at 0 and 1 and again at 0. §7.10.2.1: size() follows
// the inserts. No index here is invalid, so no warning is expected.

module test_queue_insert_positions;
  int q[$];
  string s[$];

  initial begin
    q.insert(0, 1);
    q.insert(1, 2);
    q.insert(1, 3);
    q.insert(q.size(), 4);
    foreach (q[i]) $display("q%0d=%0d", i, q[i]);
    $display("size=%0d", q.size());
    s.insert(0, "a");
    s.insert(1, "b");
    s.insert(0, "c");
    foreach (s[i]) $display("s%0d=%s", i, s[i]);
    q.delete(1);
    q.insert(1, 5);
    $display("after delete/insert: %0d %0d %0d", q[0], q[1], q[2]);
  end
endmodule

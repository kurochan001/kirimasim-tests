/*
:name: test_queue_size_method
:description: size() of a queue is 0 when the queue is empty and follows every push, insert and delete, and the elements of an assignment pattern (IEEE 1800-2023 Section 7.10.2.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.2.1 7.10.2.3 7.10.2.6 7.10
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_size_method.expected
*/
// IEEE 1800-2023 §7.10.2.1: size() returns the number of elements of a queue,
// which is 0 for an empty queue. §7.10.2.6: push_front() and push_back() add
// one element. §7.10.2.3: delete(index) removes one. The test starts with two
// empty queues, adds three elements to the int queue and removes the middle
// one, assigns the int queue from an assignment pattern, and empties the
// string queue. It prints only sizes and the first and last elements.

module test_queue_size_method;
  int q[$];
  string s[$];
  int a[$];

  initial begin
    $display("start: %0d %0d", q.size(), s.size());
    q.push_back(1);
    q.push_back(2);
    q.push_front(0);
    $display("after 3 pushes: %0d", q.size());
    q.delete(1);
    $display("after delete(1): %0d first=%0d last=%0d", q.size(), q[0], q[$]);
    a = '{4, 5, 6, 7};
    $display("pattern: %0d last=%0d", a.size(), a[a.size() - 1]);
    s.push_back("x");
    s.push_back("y");
    s.delete();
    $display("string after delete: %0d", s.size());
  end
endmodule

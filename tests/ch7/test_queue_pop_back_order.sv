/*
:name: test_queue_pop_back_order
:description: pop_back() removes and returns the last element and leaves the others in order, for queues of string and int, until the queue is empty (IEEE 1800-2023 Section 7.10.2.5)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.2.5 7.10.2.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_pop_back_order.expected
*/
// IEEE 1800-2023 §7.10.2.5: pop_back() removes the last element of a queue
// and returns its value; the elements before it keep their positions. The
// test pops a string queue from three elements to empty, printing the returned
// string and the new last element, and then pops the last of two int elements.
// §7.10.2.1: size() follows each pop. It never pops an empty queue, whose
// result the standard leaves as the default of the element type.

module test_queue_pop_back_order;
  string s[$];
  string v;
  int n[$];
  int x;

  initial begin
    s.push_back("a");
    s.push_back("b");
    s.push_back("c");
    v = s.pop_back();
    $display("popped '%s' size=%0d last='%s'", v, s.size(), s[s.size() - 1]);
    v = s.pop_back();
    $display("popped '%s' size=%0d last='%s'", v, s.size(), s[s.size() - 1]);
    v = s.pop_back();
    $display("popped '%s' size=%0d", v, s.size());
    n.push_back(9);
    n.push_back(8);
    x = n.pop_back();
    $display("int %0d size %0d last %0d", x, n.size(), n[n.size() - 1]);
  end
endmodule

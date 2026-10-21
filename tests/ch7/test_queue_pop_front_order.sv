/*
:name: test_queue_pop_front_order
:description: pop_front() removes and returns the first element and shifts the others, for queues of string and int, until the queue is empty (IEEE 1800-2023 Section 7.10.2.4)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.2.4 7.10.2.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_pop_front_order.expected
*/
// IEEE 1800-2023 §7.10.2.4: pop_front() removes the first element of a queue
// and returns its value; the other elements keep their order and move one
// position towards the front. The test pops a string queue from three elements
// to empty, printing the returned string and the new first element, and then
// pops the only element of an int queue. §7.10.2.1: size() follows each pop.
// It never pops an empty queue, whose result the standard leaves as the
// default of the element type.

module test_queue_pop_front_order;
  string s[$];
  string v;
  int n[$];
  int x;

  initial begin
    s.push_back("a");
    s.push_back("b");
    s.push_back("c");
    v = s.pop_front();
    $display("popped '%s' size=%0d first='%s'", v, s.size(), s[0]);
    v = s.pop_front();
    $display("popped '%s' size=%0d first='%s'", v, s.size(), s[0]);
    v = s.pop_front();
    $display("popped '%s' size=%0d", v, s.size());
    n.push_back(7);
    x = n.pop_front();
    $display("int %0d size %0d", x, n.size());
  end
endmodule

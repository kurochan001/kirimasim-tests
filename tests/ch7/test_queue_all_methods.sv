/*
:name: test_queue_all_methods
:description: a queue supports push_back, push_front, insert, pop_front, pop_back and delete at an index and with no argument
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_all_methods.expected
*/
// IEEE 1800-2023 7.10.1: a queue supports the methods of 7.10.2. The test
// builds a queue with push_back and push_front, inserts in the middle, and
// reads all four elements; it then removes one element from each end, deletes
// the remaining middle element by index, and deletes all elements with the
// no-argument form. Each printed element and size follows the method
// definitions, so a tool that omits a method, or that inserts or deletes at
// the wrong end, prints another sequence or size.

module test_queue_all_methods;
  int q[$];
  int a, b;

  initial begin
    q.push_back(1);
    q.push_back(2);
    q.push_front(0);
    q.insert(2, 9);
    $display("all=%0d %0d %0d %0d size=%0d", q[0], q[1], q[2], q[3], q.size());
    a = q.pop_front();
    b = q.pop_back();
    $display("pop=%0d %0d left=%0d %0d size=%0d", a, b, q[0], q[1], q.size());
    q.delete(1);
    $display("delete=%0d size=%0d", q[0], q.size());
    q.delete();
    $display("empty=%0d", q.size());
  end
endmodule

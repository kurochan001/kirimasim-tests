/*
:name: test_dynamic_array_and_queue_operations
:description: a dynamic array resizes with new and clears with delete, and a queue resizes to the assigned queue while a bounded queue discards elements above its bound
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5.2 7.5.3 7.10.1 7.10.2 7.10.2.2 7.10.2.3 7.10.2.6 7.10.2.7
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dynamic_array_and_queue_operations.expected
*/
// IEEE 1800-2023 7.5.2 and 7.5.3: size() takes no argument and delete() takes
// no argument and removes all elements. 7.10.1: a queue resizes itself to
// accommodate any queue value written to it, subject to a declared upper bound.
// 7.10.2 with 7.10.2.2, 7.10.2.3, 7.10.2.6 and 7.10.2.7: insert takes an index
// and an item, delete takes an optional index, and push_front and push_back
// take one item. The test grows and clears a dynamic array, builds a queue with
// the methods, replaces its contents with an assignment, and assigns five
// items to a queue bounded at index 3.

module test_dynamic_array_and_queue_operations;
  int dyn[];
  int q[$];
  int qb[$:3];
  int n;

  initial begin
    dyn = new[3];
    dyn[0] = 1;
    dyn[1] = 2;
    dyn[2] = 3;
    $display("dyn_size=%0d", dyn.size());
    dyn.delete();
    $display("dyn_after=%0d", dyn.size());
    q.push_back(1);
    q.push_front(0);
    q.insert(1, 5);
    q.push_back(2);
    $display("q=%0d %0d %0d %0d size=%0d", q[0], q[1], q[2], q[3], q.size());
    q.delete(1);
    $display("q_del=%0d %0d %0d size=%0d", q[0], q[1], q[2], q.size());
    q = '{7, 8};
    $display("q_assign=%0d %0d size=%0d", q[0], q[1], q.size());
    qb = '{1, 2, 3, 4, 5};
    n = qb.size();
    $display("qb_size=%0d first=%0d last=%0d", n, qb[0], qb[n - 1]);
    qb.push_back(9);
    n = qb.size();
    $display("qb_after_push=%0d last=%0d", n, qb[n - 1]);
    qb.delete();
    $display("qb_empty=%0d", qb.size());
  end
endmodule

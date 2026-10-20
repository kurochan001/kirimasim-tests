/*
:name: test_queue_method_edges
:description: Queue methods at their limits: size of an empty queue, insert at the end and ignored inserts at a negative, too large or unknown index, push_front, and pop_front and pop_back that remove an end or, on an empty queue, return the value of a nonexistent element (IEEE 1800-2023 Section 7.10.2.2)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.2.2 7.10.2.1 7.10.2.4 7.10.2.5 7.10.2.6 7.4.5
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_queue_method_edges.expected
*/
// IEEE 1800-2023 §7.10.2.1: size() of an empty queue is 0. §7.10.2.6:
// push_front() adds an element before the first. §7.10.2.2: insert(index,
// item) puts the item at index, which may equal the size (the end); an index
// that is negative, larger than the size or has x or z bits leaves the queue
// unchanged. §7.10.2.4, §7.10.2.5: pop_front() and pop_back() remove and
// return the first and the last element; on an empty queue they change
// nothing and return what reading a nonexistent element gives (Table 7-1 in
// 7.4.5): 0 for int, x for logic.
//
// Icarus Verilog 13.0 gives x for pop_front() and pop_back() on the empty int
// queue, and the int variables then hold x.

module test_queue_method_edges;
  int q[$];
  logic [3:0] lq[$];
  integer bad;
  int first, last, e1, e2;
  logic [3:0] le;

  function automatic string items();
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    $display("empty size=%0d", q.size());
    q.push_front(2);
    q.push_front(1);
    q.insert(2, 3);
    q.insert(0, 0);
    q.insert(-1, 9);
    q.insert(5, 9);
    bad = 'x;
    q.insert(bad, 9);
    $display("after inserts:%s, size=%0d", items(), q.size());
    first = q.pop_front();
    last = q.pop_back();
    $display("popped %0d and %0d, left:%s", first, last, items());
    q.delete();
    e1 = q.pop_front();
    e2 = q.pop_back();
    le = lq.pop_front();
    $display("from empty queues: %0d %0d %b, sizes %0d %0d", e1, e2, le, q.size(), lq.size());
  end
endmodule

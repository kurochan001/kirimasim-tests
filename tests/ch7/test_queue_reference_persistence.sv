/*
:name: test_queue_reference_persistence
:description: A reference to a queue element held by a task stays on that element when other methods change the queue, and becomes outdated when the element is deleted or the whole queue is assigned (IEEE 1800-2023 Section 7.10.3)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.3 13.5.2 7.10.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_reference_persistence.expected
*/
// IEEE 1800-2023 §7.10.3: when a queue method changes a queue, a reference to
// an element that the method does not remove stays valid; a reference to a
// removed element, and every reference after an assignment to the whole queue,
// becomes outdated. §13.5.2: an outdated element goes on existing for the task
// that holds it, but is no longer part of the queue. watch1 holds the element
// 20 and watch2 the element 10. push_front at 1 moves both to new indices, so
// the write of watch1 at 2 changes the queue. delete(2) at 5 removes the
// element of watch1, whose write at 6 then leaves the queue alone. The
// assignment of the whole queue at 7 outdates watch2, so its write at 8 does
// not reach the queue either.
//
// In Verilator 5.052 a reference keeps the position of the element instead:
// after delete(2) watch1 writes the element that moved into its place, and
// after the assignment of the whole queue watch2 reads memory that is no longer
// the queue's.

`timescale 1ns/1ns

module test_queue_reference_persistence;
  int q[$] = '{10, 20, 30};

  function automatic string items(int v[$]);
    string s = "";
    foreach (v[i]) s = {s, $sformatf(" %0d", v[i])};
    return s;
  endfunction

  task automatic watch1(ref int r);
    #2 r = r + 1;
    #4 r = r + 1;
    $display("watch1 at %0t: r=%0d", $time, r);
  endtask

  task automatic watch2(ref int r);
    #8 r = r + 1;
    $display("watch2 at %0t: r=%0d", $time, r);
  endtask

  initial begin
    fork
      watch1(q[1]);
      watch2(q[0]);
    join_none
    #1 q.push_front(5);
    #2 $display("t=%0t: q =%s", $time, items(q));
    #2 q.delete(2);
    #2 $display("t=%0t: q =%s", $time, items(q));
    q = {q, 40};
    #2 $display("t=%0t: q =%s", $time, items(q));
  end
endmodule

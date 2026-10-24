/*
:name: test_queue_refs_outdated_by_bounded_push_and_assignment
:description: a queue assignment that gives the same value as push_back outdates every reference to the old elements while push_back keeps them, and push_front on a full bounded queue outdates only the reference to the dropped last element (IEEE 1800-2023 Sections 7.10.4, 7.10.3)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.4 7.10.3 13.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_refs_outdated_by_bounded_push_and_assignment.expected
*/
// IEEE 1800-2023 §7.10.4: an assignment such as p = {p, 4} leaves p with the
// same value as p.push_back(4), but it outdates every reference to the
// elements of p, which the method does not. §7.10.3: push_front and insert
// never outdate references, except that on a bounded queue they delete the
// element with the highest index when the new size would exceed the bound,
// and a reference to that element becomes outdated. §13.5.2: a task can still
// use an outdated element, but its writes no longer reach the queue.
// Four tasks hold references: to p[1] and m[1], whose queues are updated at
// time 1 by an assignment and by push_back, and to b[0] and b[2] of the full
// bounded queue b [$:2], which push_front at time 1 shifts (b[0] to index 1)
// and drops (b[2]). The tasks write at times 2 to 5, one at a time, and the
// queues are printed at time 6: only the writes through m[1] and the old b[0]
// show.
// Icarus Verilog 13.0 does not support ref arguments.

`timescale 1ns/1ns

module test_queue_refs_outdated_by_bounded_push_and_assignment;
  int p[$] = '{1, 2, 3};
  int m[$] = '{1, 2, 3};
  int b[$:2] = '{10, 20, 30};

  function automatic string items(int v[$]);
    string s = "";
    foreach (v[i]) s = {s, $sformatf(" %0d", v[i])};
    return s;
  endfunction

  task automatic write_at(ref int r, input int t, input int value, input string name);
    #t r = value;
    $display("%s at %0t: r=%0d", name, $time, r);
  endtask

  initial begin
    fork
      write_at(p[1], 2, 200, "p[1] holder");
      write_at(m[1], 3, 300, "m[1] holder");
      write_at(b[0], 4, 11, "b[0] holder");
      write_at(b[2], 5, 31, "b[2] holder");
    join_none
    #1;
    p = {p, 4};
    m.push_back(4);
    b.push_front(5);
    $display("t=%0t: p =%s m =%s equal=%0d b =%s", $time, items(p), items(m), p == m, items(b));
    #5;
    $display("t=%0t: p =%s", $time, items(p));
    $display("t=%0t: m =%s", $time, items(m));
    $display("t=%0t: b =%s", $time, items(b));
  end
endmodule

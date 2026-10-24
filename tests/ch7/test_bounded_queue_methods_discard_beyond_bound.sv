/*
:name: test_bounded_queue_methods_discard_beyond_bound
:description: push_back, push_front, insert and a write to [$+1] on a full bounded queue act as on an unbounded queue and then drop, with a warning, the element above the bound (IEEE 1800-2023 Section 7.10.5)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.5 7.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_bounded_queue_methods_discard_beyond_bound.expected
:expected_stderr_regex: (?i:\bwarn(?:ing)?\b|%Warning-)
*/
// IEEE 1800-2023 §7.10: a queue declared [$:N] has no index above N. §7.10.5:
// an operation on a bounded queue behaves as on an unbounded one, except that
// when a write leaves elements beyond the bound, all of them are discarded and
// a warning shall be issued.
// bq is declared [$:2], so it keeps at most three elements, and it starts
// full. push_back puts the new element last, where it is dropped; push_front
// and insert move the old last element past index 2, where it is dropped; the
// write to bq[3] ($+1) appends an element that is dropped as well. The last
// two operations stay within the bound. The warning that the overflows
// require is checked in the messages of the run.
// In Verilator 5.052, insert() grows the full queue to four elements.

module test_bounded_queue_methods_discard_beyond_bound;
  int bq[$:2] = '{1, 2, 3};

  task automatic show(string label);
    string s = $sformatf("size=%0d:", bq.size());
    foreach (bq[i]) s = {s, $sformatf(" %0d", bq[i])};
    $display("%s %s", label, s);
  endtask

  initial begin
    show("declared:");
    bq.push_back(4);
    show("push_back(4):");
    bq.push_front(0);
    show("push_front(0):");
    bq.insert(1, 9);
    show("insert(1, 9):");
    bq[3] = 10;
    show("bq[3] = 10:");
    bq.delete(0);
    show("delete(0):");
    bq.push_back(11);
    show("push_back(11):");
  end
endmodule

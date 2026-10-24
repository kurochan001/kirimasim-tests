/*
:name: test_bounded_queue_assign_discards_beyond_bound
:description: assigning a longer queue value to a bounded queue keeps the elements up to the bound and drops, with a warning, those beyond it (IEEE 1800-2023 Section 7.10.5)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.5 7.10 7.10.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_bounded_queue_assign_discards_beyond_bound.expected
:expected_stderr_regex: (?i:\bwarn(?:ing)?\b|%Warning-)
*/
// IEEE 1800-2023 §7.10: a queue declared [$:N] has no index above N. §7.10.5:
// an operation on a bounded queue behaves as on an unbounded one, except that
// when a write leaves elements beyond the bound, all of them are discarded and
// a warning shall be issued. This holds for assignments (§7.10.4) as well as
// for methods.
// bq is declared [$:2], so it keeps its elements with indices 0 to 2. Each
// assignment of a concatenation of five elements, with the old value at the
// end or at the start, or of a five-element unbounded queue, keeps the first
// three; an assignment of two elements is within the bound. The warning that
// the overflows require is checked in the messages of the run.
// Icarus Verilog 13.0 rejects a bounded queue inside a concatenation. The
// assignment bq = big keeps only two elements in Verilator 5.052.

module test_bounded_queue_assign_discards_beyond_bound;
  int bq[$:2] = '{1, 2, 3};
  int big[$] = '{20, 21, 22, 23, 24};

  task automatic show(string label);
    string s = $sformatf("size=%0d:", bq.size());
    foreach (bq[i]) s = {s, $sformatf(" %0d", bq[i])};
    $display("%s %s", label, s);
  endtask

  initial begin
    bq = {bq, 5, 6};
    show("bq = {bq, 5, 6}:");
    bq = {7, 8, bq};
    show("bq = {7, 8, bq}:");
    bq = big;
    show("bq = big:");
    bq = {30, 31};
    show("bq = {30, 31}:");
  end
endmodule

/*
:name: test_unpacked_concat_bounded_queue_overflow
:description: an unpacked array concatenation assigned to a bounded queue keeps the elements up to the bound and drops, with a warning, the elements beyond it (IEEE 1800-2023 Section 10.10)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_unpacked_concat_bounded_queue_overflow.expected
:expected_stderr_regex: (?i:\bwarn(?:ing)?\b|%Warning-)
*/
// IEEE 1800-2023 §10.10: the items of an unpacked array concatenation are
// laid out left to right, an array item giving all of its elements in order.
// When the target is a bounded queue and the result has more elements than
// the queue can hold, the elements past the bound are ignored and a warning
// shall be issued.
// bq is declared [$:3], so it holds at most four elements. Two concatenations
// have five elements, made of single items, a fixed-size array and a dynamic
// array; they keep their first four. A concatenation of exactly four elements
// and an empty one are within the bound and keep all of their elements. The
// warning for the overflows is checked in the messages of the run.
// Icarus Verilog 13.0 rejects array items in a concatenation whose target is a
// bounded queue, and the C++ code that Verilator 5.052 generates for them does
// not compile, so the expected output follows the clause alone.

module test_unpacked_concat_bounded_queue_overflow;
  int bq[$:3];
  int fa[3] = '{11, 12, 13};
  int da[];

  task automatic show(string label);
    string s = $sformatf("size=%0d:", bq.size());
    foreach (bq[i]) s = {s, $sformatf(" %0d", bq[i])};
    $display("%s %s", label, s);
  endtask

  initial begin
    da = '{21, 22};
    bq = {1, fa, 2};
    show("{1, fa, 2}");
    bq = {da, fa};
    show("{da, fa}");
    bq = {fa, 4};
    show("{fa, 4}");
    bq = {};
    show("{}");
  end
endmodule

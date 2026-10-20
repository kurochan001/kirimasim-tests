/*
:name: test_real_queue_sort_min_max
:description: sort, rsort, min and max on a queue of reals order the elements by their real values (IEEE 1800-2023 Section 7.12.2)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.2 7.12.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_queue_sort_min_max.expected
*/
// IEEE 1800-2023 §7.12.2: sort() and rsort() order the elements of an array
// of any element type that has relational operators, reals included, by
// their values; §7.12.1: min() and max() return queues with the smallest and
// the largest element. Values that differ only in their fractions, 1.9, 1.1
// and 1.5, keep that order, as do 2.25, -0.5 and 2.5.

module test_real_queue_sort_min_max;
  real q[$] = {1.9, 1.1, 1.5};
  real r[$] = {2.25, -0.5, 2.5};
  real mn[$], mx[$];

  initial begin
    q.sort();
    $display("sort: %.2f %.2f %.2f", q[0], q[1], q[2]);
    q.rsort();
    $display("rsort: %.2f %.2f %.2f", q[0], q[1], q[2]);
    mn = q.min();
    mx = q.max();
    $display("min: %.2f, max: %.2f", mn[0], mx[0]);
    r.sort();
    $display("sort: %.2f %.2f %.2f", r[0], r[1], r[2]);
  end
endmodule

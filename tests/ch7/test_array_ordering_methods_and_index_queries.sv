/*
:name: test_array_ordering_methods_and_index_queries
:description: sort, rsort and reverse reorder an unpacked array as declared, and the iterator index numbers the slowest-varying dimension first
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.2 7.12.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_ordering_methods_and_index_queries.expected
*/
// IEEE 1800-2023 7.12.2: sort and rsort order an unpacked array in ascending
// and descending order, reverse reverses the element order, each method
// returns void and the iterator argument defaults to item, and a with clause
// selects the sort expression. 7.12.4: the iterator index method numbers the
// slowest-varying dimension 1 and successively faster dimensions higher, and
// an omitted dimension means 1. The test sorts, reverse-sorts and reverses a
// fixed array and a queue, sorts with an iterator expression, and sums the
// dimension-1 and dimension-2 indices of a two-dimensional array.

module test_array_ordering_methods_and_index_queries;
  int a[6];
  int q[$];
  int m[2][3];

  initial begin
    a = '{5, 1, 4, 2, 3, 0};
    a.sort();
    $display("sort=%0d %0d %0d %0d %0d %0d", a[0], a[1], a[2], a[3], a[4], a[5]);
    a.rsort();
    $display("rsort=%0d %0d %0d %0d %0d %0d", a[0], a[1], a[2], a[3], a[4], a[5]);
    a.reverse();
    $display("reverse=%0d %0d %0d %0d %0d %0d", a[0], a[1], a[2], a[3], a[4], a[5]);
    q = '{3, 1, 2};
    q.sort;
    $display("q_sort=%0d %0d %0d size=%0d", q[0], q[1], q[2], q.size());
    a = '{5, 1, 4, 2, 3, 0};
    a.sort(x) with (-x);
    $display("with=%0d %0d %0d %0d %0d %0d", a[0], a[1], a[2], a[3], a[4], a[5]);
    for (int i = 0; i < 2; i++)
      for (int j = 0; j < 3; j++)
        m[i][j] = i * 10 + j;
    $display("dim1=%0d dim2=%0d default=%0d",
             m.sum with (item.index(1)), m.sum with (item.index(2)),
             m.sum with (item.index()));
  end
endmodule

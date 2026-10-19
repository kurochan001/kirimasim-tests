/*
:name: test_array_map_method
:description: The map() array method returns an array with the same range or keys whose elements are the with expression for each element, using item or a named iterator and its index, with the self-determined type of the expression (IEEE 1800-2023 Section 7.12.5)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.5 7.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_map_method.expected
*/
// IEEE 1800-2023 §7.12.5: map() returns an unpacked array with the range of
// the source, or with its keys for an associative array, in which each
// element is replaced by the with expression; the elements have the
// self-determined type of that expression. Without an argument the iterator is
// item; with one it has that name, and its index() method gives the index of
// the element (7.12). The fixed array f keeps its range [2:4], the
// associative array keeps its keys, and the comparison gives 1-bit elements.

module test_array_map_method;
  int q[$] = '{3, 1, 4};
  int q10[$];
  int f[2:4] = '{5, 6, 7};
  int g[2:4];
  int aa[string];
  int sq[string];
  bit big[2:4];

  initial begin
    q10 = q.map() with (item * 10);
    $display("q10 = %0d %0d %0d", q10[0], q10[1], q10[2]);

    g = f.map(x) with (x + x.index);
    foreach (g[i]) $display("g[%0d] = %0d", i, g[i]);

    big = f.map(x) with (x > 5);
    $display("big = %b%b%b, element width %0d", big[2], big[3], big[4], $bits(big[2]));

    aa["one"] = 1;
    aa["three"] = 3;
    sq = aa.map() with (item * item);
    foreach (sq[k]) $display("sq[%s] = %0d", k, sq[k]);
  end
endmodule

/*
:name: test_array_ordering_methods_with_and_iterator
:description: sort() and rsort() order a dynamic array, a fixed array and a queue by the element value or by a with expression using item or a named iterator, reverse() reverses, and shuffle() leaves a permutation of the elements (IEEE 1800-2023 Section 7.12.2)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_ordering_methods_with_and_iterator.expected
*/
// IEEE 1800-2023 §7.12.2: the ordering methods are void functions with an
// iterator argument whose name defaults to item, and they reorder fixed-size
// and dynamically sized unpacked arrays. sort() puts the elements in
// ascending order and rsort() in descending order, of the element values or,
// with a with clause, of the with expression; reverse() reverses the order;
// shuffle() puts the elements in a random order.
// Every with expression below gives distinct values, so the order is fixed
// even though the standard does not say that sorting is stable. a is sorted by
// its last decimal digit with the iterator x, then reverse-sorted by it with
// item; the strings are sorted by value and then by length. shuffle's order
// is random, so the test prints only the size, the sum and the sorted result,
// which show that the elements were kept.
// Icarus Verilog 13.0 does not support unpacked structures or these method
// calls. The release Verilator 5.052 sorts the int queue b as if its elements
// were unsigned (2 3 -1, then -1 3 2).

module test_array_ordering_methods_with_and_iterator;
  typedef struct {
    int key;
    string name;
  } pair_t;

  int a [] = '{25, 13, 7, 4};
  int b [$] = '{3, -1, 2};
  int f [1:4] = '{8, 1, 6, 3};
  string s [$] = '{"pear", "fig", "apple"};
  pair_t p [3] = '{'{key: 2, name: "two"}, '{key: 3, name: "three"}, '{key: 1, name: "one"}};
  int sh [] = '{1, 2, 3, 4, 5, 6, 7, 8};

  initial begin
    a.sort(x) with (x % 10);
    $display("a.sort(x) with (x %% 10): %0d %0d %0d %0d", a[0], a[1], a[2], a[3]);
    a.rsort with (item % 10);
    $display("a.rsort with (item %% 10): %0d %0d %0d %0d", a[0], a[1], a[2], a[3]);
    b.sort();
    $display("b.sort(): %0d %0d %0d", b[0], b[1], b[2]);
    b.rsort;
    $display("b.rsort: %0d %0d %0d", b[0], b[1], b[2]);
    f.sort();
    $display("f.sort(): f[1]=%0d f[2]=%0d f[3]=%0d f[4]=%0d", f[1], f[2], f[3], f[4]);
    f.reverse();
    $display("f.reverse(): f[1]=%0d f[2]=%0d f[3]=%0d f[4]=%0d", f[1], f[2], f[3], f[4]);
    s.sort();
    $display("s.sort(): %s %s %s", s[0], s[1], s[2]);
    s.sort(w) with (w.len());
    $display("s.sort(w) with (w.len()): %s %s %s", s[0], s[1], s[2]);
    s.reverse;
    $display("s.reverse: %s %s %s", s[0], s[1], s[2]);
    p.rsort with (item.key);
    $display("p.rsort with (item.key): %s %s %s", p[0].name, p[1].name, p[2].name);
    sh.shuffle();
    $display("sh.shuffle(): size=%0d sum=%0d", sh.size(), sh.sum());
    sh.sort();
    $display("sorted again: %0d %0d %0d %0d %0d %0d %0d %0d", sh[0], sh[1], sh[2], sh[3],
             sh[4], sh[5], sh[6], sh[7]);
  end
endmodule

/*
:name: test_map_selects_order_and_empty
:description: a select or a method call can follow the with clause of map(), map() of a descending range gives each element the index it had, map() of an empty array is empty, and map() of a queue or an associative array with negative keys keeps the order and the keys, leaving the source unchanged (IEEE 1800-2023 Sections 7.12.5, 7.12)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.5 7.12 7.12.4 7.12.3 7.6 7.8.4 7.9.4 7.9.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_map_selects_order_and_empty.expected
*/
// IEEE 1800-2023 §7.12: the call of an array manipulation method can be used
// as a value inside an expression; selects and methods of the result follow
// the with clause. §7.12.5: map() returns an array with the range, or the
// indices, of the source, with each element replaced by the with expression,
// and it does not change the source.
// - a.map() with (item * 3) is 3 6 9 12, and [2] selects 9; the sum
//   (§7.12.3) of a.map() with (item * item) is 1+4+9+16 = 30.
// - d has the range [3:1] and holds 30 20 10 from left to right; the index
//   method gives the declared index (§7.12.4), so x.index * 100 + x is 330
//   at index 3, 220 at 2 and 110 at 1, and r, with the same range, gets them
//   at the same indices.
// - e was never sized, so map() gives an empty array and eq gets size 0.
// - ik has the keys -2 and 7; the result has the same 2 keys, and first()
//   and next() visit them in increasing order (§7.8.4: signed numeric order
//   for int keys; §7.9.4, §7.9.6): -2 gets -2*10 + 5 = -15 and 7 gets
//   7*10 + 1 = 71.
// - q.map() with (item - 1) keeps the order of q: 8 7 6, and q stays 9 8 7.
// The expected output follows the standard alone. Icarus Verilog 13.0 does
// not support the with clause of array methods. The 5.052 release of the
// simulator named Verilator supports neither a method call on the result of
// map() nor map() of a fixed-size array assigned to an unpacked array.

module test_map_selects_order_and_empty;
  int a[4] = '{1, 2, 3, 4};
  int d[3:1] = '{30, 20, 10};
  int r[3:1];
  int e[];
  int eq[$];
  int ik[int];
  int ik2[int];
  int q[$] = '{9, 8, 7};
  int q2[$];
  int k;

  initial begin
    $display("select: %0d", a.map() with (item * 3)[2]);
    $display("sum: %0d", a.map() with (item * item).sum());
    r = d.map(x) with (x.index * 100 + x);
    $display("r: %0d %0d %0d", r[3], r[2], r[1]);
    eq = e.map() with (item + 1);
    $display("empty: %0d", eq.size());
    ik[7] = 1;
    ik[-2] = 5;
    ik2 = ik.map(x) with (x.index * 10 + x);
    void'(ik2.first(k));
    $write("ik2: %0d, [%0d]=%0d", ik2.num(), k, ik2[k]);
    void'(ik2.next(k));
    $display(" [%0d]=%0d", k, ik2[k]);
    q2 = q.map() with (item - 1);
    $display("q2: %0d %0d %0d, q: %0d %0d %0d", q2[0], q2[1], q2[2], q[0], q[1], q[2]);
  end
endmodule

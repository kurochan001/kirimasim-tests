/*
:name: test_array_assign_resize_concat_source_slice_overlap
:description: assigning to a dynamic array or queue resizes it to the number of source elements, the source can be an unpacked array concatenation of slices and items, and an assignment to a slice is one assignment, so an overlapping copy within one array moves the old values (IEEE 1800-2023 Section 7.6)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.6 10.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_assign_resize_concat_source_slice_overlap.expected
*/
// IEEE 1800-2023 §7.6: when the target of an array assignment is a dynamic
// array or a queue, it is first resized to the number of elements of the
// source, then each source element is assigned to the target element in the
// same left-to-right position. The source can be an expression made of slices
// and unpacked array concatenations (§10.10). An assignment whose left-hand
// side contains a slice is a single assignment to the whole slice.
// d starts with 5 elements and q with 1, and both take the 3 elements of fa
// [1:3]. The concatenations mix slices of a fixed array, a dynamic array and
// a string array with single items. ov[1:4] = ov[0:3] and ow[0:3] = ow[1:4]
// copy overlapping parts of one array: as single assignments they read all
// old values first, so neither copy repeats one value along the slice.
// Icarus Verilog 13.0 stops with an internal assertion on q = fa. Verilator
// 5.052 rejects the slice d[1:2] of a dynamic array and stops with an internal
// error on the concatenation of slices of fa.

module test_array_assign_resize_concat_source_slice_overlap;
  int fa [1:3] = '{10, 20, 30};
  string sd [0:4] = '{"a", "b", "c", "d", "e"};
  int ov [0:4] = '{1, 2, 3, 4, 5};
  int ow [0:4] = '{1, 2, 3, 4, 5};
  int d[];
  int q[$];
  string p[];

  initial begin
    d = new[5];
    q = '{7};
    $display("before: d size=%0d q size=%0d", d.size(), q.size());
    d = fa;
    q = fa;
    $display("from fa: d size=%0d %0d %0d %0d; q size=%0d %0d %0d %0d", d.size(), d[0], d[1],
             d[2], q.size(), q[0], q[1], q[2]);
    d = {fa[2:3], 99, fa[1:1]};
    $display("concat into d: size=%0d %0d %0d %0d %0d", d.size(), d[0], d[1], d[2], d[3]);
    q = {d[1:2], q[0]};
    $display("concat into q: size=%0d %0d %0d %0d", q.size(), q[0], q[1], q[2]);
    p = {sd[1:2], "x", sd[4:4], sd[0]};
    $display("concat into p: size=%0d %s %s %s %s %s", p.size(), p[0], p[1], p[2], p[3], p[4]);
    ov[1:4] = ov[0:3];
    ow[0:3] = ow[1:4];
    $display("overlap: ov=%0d %0d %0d %0d %0d ow=%0d %0d %0d %0d %0d", ov[0], ov[1], ov[2],
             ov[3], ov[4], ow[0], ow[1], ow[2], ow[3], ow[4]);
  end
endmodule

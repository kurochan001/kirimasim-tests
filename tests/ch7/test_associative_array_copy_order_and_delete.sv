/*
:name: test_associative_array_copy_order_and_delete
:description: an associative array copies and compares as a whole, enumerates its indices in signed int order, returns the Table 7-1 value for a missing entry, and deletes one entry or all
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8 7.8.5 7.9.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_associative_array_copy_order_and_delete.expected
*/
// IEEE 1800-2023 7.8: an associative array is unpacked; whole copy and
// comparison are supported, and other expressions select an individual
// element. 7.8.5: when the index type defines a relational comparison, the
// entries are ordered by that index-type order, so an int index enumerates in
// signed numeric order. 7.9.2: delete() with an index removes that entry and
// without an index removes all entries. The test copies and compares the
// array, walks first/next/last, reads a missing entry (Table 7-1 gives x for a
// four-state int), and deletes one entry and then all.

module test_associative_array_copy_order_and_delete;
  int aa[int];
  int bb[int];
  int k;

  initial begin
    aa[3] = 30;
    aa[-1] = -10;
    aa[0] = 0;
    bb = aa;
    $display("size=%0d equal=%0d", aa.size(), aa == bb);
    bb[3] = 31;
    $display("after_change_equal=%0d", aa == bb);
    if (aa.first(k)) $display("first=%0d", k);
    if (aa.next(k)) $display("next=%0d", k);
    if (aa.next(k)) $display("next2=%0d", k);
    if (aa.last(k)) $display("last=%0d", k);
    $display("missing=%0d", aa[99]);
    aa.delete(0);
    $display("after_delete_size=%0d has0=%0d", aa.size(), aa.exists(0));
    aa.delete();
    $display("after_clear=%0d", aa.size());
  end
endmodule

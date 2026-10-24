/*
:name: test_array_locator_first_last_by_range_and_min_tie
:description: find_first and find_last pick the match closest to the leftmost or rightmost index, which for a descending range is the highest or lowest index and for an associative array follows first() and last(); min() returns one element even when several tie (IEEE 1800-2023 Section 7.12.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_locator_first_last_by_range_and_min_tie.expected
*/
// IEEE 1800-2023 §7.12.1: for find_first, find_first_index, find_last and
// find_last_index, the first or last element is the one closest to the
// leftmost or rightmost indexed element; for an associative array it is the
// one closest to the index that first() or last() returns. min() returns the
// element whose with expression is smallest, and only one element when
// several have that value.
// dn [4:1] and up [1:4] hold the same values in the same left-to-right order,
// so their first and last matches are the same elements at different
// indices. aa has int keys, ordered from -5 to 10. In m two elements have the
// smallest value, and with (item % 3) the elements 4 and 7 tie; which one min
// returns is not fixed, so only its expression value is printed. Every
// locator returns a queue; the element of each one-element result is printed.
// Icarus Verilog 13.0 does not support locator methods with a with clause.
// The release Verilator 5.052 counts positions from 0, not by the ranges,
// takes the rightmost element of dn as its first, and orders the int keys
// of aa as unsigned values.

module test_array_locator_first_last_by_range_and_min_tie;
  int dn [4:1] = '{7, 0, 9, 5};
  int up [1:4] = '{7, 0, 9, 5};
  int aa [int];
  int m [] = '{4, 2, 7, 2};
  int q[$];
  int f, fi, l, li;

  initial begin
    aa[10] = 4;
    aa[-5] = 6;
    aa[3] = 8;
    aa[0] = -1;
    q = dn.find_first with (item > 0);
    f = q[0];
    q = dn.find_first_index with (item > 0);
    fi = q[0];
    q = dn.find_last with (item > 0);
    l = q[0];
    q = dn.find_last_index with (item > 0);
    li = q[0];
    $display("dn [4:1]: first=%0d at %0d, last=%0d at %0d", f, fi, l, li);
    q = up.find_first with (item > 0);
    f = q[0];
    q = up.find_first_index with (item > 0);
    fi = q[0];
    q = up.find_last with (item > 0);
    l = q[0];
    q = up.find_last_index with (item > 0);
    li = q[0];
    $display("up [1:4]: first=%0d at %0d, last=%0d at %0d", f, fi, l, li);
    q = aa.find_first with (item > 0);
    f = q[0];
    q = aa.find_first_index with (item > 0);
    fi = q[0];
    q = aa.find_last with (item > 0);
    l = q[0];
    q = aa.find_last_index with (item > 0);
    li = q[0];
    $display("aa: first=%0d at %0d, last=%0d at %0d", f, fi, l, li);
    q = m.min();
    $display("min: size=%0d value=%0d", q.size(), q[0]);
    q = m.min with (item % 3);
    $display("min with (item %% 3): size=%0d expression=%0d", q.size(), q[0] % 3);
  end
endmodule

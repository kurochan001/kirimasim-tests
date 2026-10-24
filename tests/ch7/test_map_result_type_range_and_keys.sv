/*
:name: test_map_result_type_range_and_keys
:description: the result of map() has elements of the self-determined type of the with expression, the range of the source array, and for an associative array its set of indices (IEEE 1800-2023 Section 7.12.5)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_map_result_type_range_and_keys.expected
*/
// IEEE 1800-2023 §7.12.5: map() returns an unpacked array with the same range
// as the source array, or the same set of indices for an associative array,
// whose elements are the values of the with expression; the type of each
// element is the self-determined type of the with expression, and the range
// and index type of the result match those of the source.
// - $bits of the result of map() on the three ints of a gives the size of
//   its elements: 4 bits for item[3:0], 8 for the size cast 8'(item), 1 for
//   the comparison item > 1 and 32 for item + 1'b1, so 12 24 3 96.
// - The array query functions applied to the result of map() on r, declared
//   [7:5], give its range: $left 7, $right 5, $size 3; copied to r2 with the
//   same range, r2[7] is 10 + 1 and r2[5] is 30 + 1.
// - map() on the associative array m gives an array with its indices x and
//   y, whose values are doubled: 2 x 8 y 18.
// The expected output follows the standard alone: Icarus Verilog 13.0 does
// not support the with clause of array methods, and the 5.052 release gives
// map() on a fixed-size array a queue as its result (it reports $bits of it
// as unsupported) and fails to compile the C++ code it generates for map() on
// the associative array.

module test_map_result_type_range_and_keys;
  int a [3] = '{1, 2, 3};
  int r [7:5] = '{10, 20, 30};
  int r2 [7:5];
  int m [string];
  int m2 [string];
  string s;

  initial begin
    m["x"] = 4;
    m["y"] = 9;
    $display("%0d %0d %0d %0d", $bits(a.map() with (item[3:0])),
             $bits(a.map() with (8'(item))), $bits(a.map() with (item > 1)),
             $bits(a.map() with (item + 1'b1)));
    $display("%0d %0d %0d", $left(r.map() with (item + 1)), $right(r.map() with (item + 1)),
             $size(r.map() with (item + 1)));
    r2 = r.map() with (item + 1);
    $display("%0d %0d", r2[7], r2[5]);
    m2 = m.map() with (item * 2);
    void'(m2.first(s));
    $write("%0d %s %0d", m2.num(), s, m2[s]);
    void'(m2.next(s));
    $display(" %s %0d", s, m2[s]);
  end
endmodule

/*
:name: test_array_query_invalid_dimension_all_x
:description: an array query function returns 'x when its first argument has no dimensions or when the dimension asked for is out of range, while $dimensions and $unpacked_dimensions return 0 for such an argument (IEEE 1800-2023 Section 20.7)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7 21.2.1.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_array_query_invalid_dimension_all_x.expected
*/
// IEEE 1800-2023 §20.7: the array query functions return integer. If their
// first argument is of a type for which $dimensions returns 0, or if the
// dimension argument is out of range, they return 'x, an integer with all
// bits x, which %h shows as xxxxxxxx (§21.2.1.3). $dimensions and
// $unpacked_dimensions themselves return 0 for a type with no dimensions.
// The first line applies all six dimension functions to a real variable;
// the second line asks a 2-dimensional array for dimensions 0, 3 and 5 and
// for the in-range dimension 2 as a contrast; the third line shows the 0
// results of the two counting functions for the real variable.

module test_array_query_invalid_dimension_all_x;
  real r;
  logic [3:0] v4 [2];

  initial begin
    $display("real: %h %h %h %h %h %h", $left(r), $right(r), $low(r), $high(r), $increment(r),
             $size(r));
    $display("range: %h %h %h %h in range: %0d %0d", $left(v4, 0), $right(v4, 3), $size(v4, 5),
             $high(v4, 3), $left(v4, 2), $size(v4, 1));
    $display("counts: %0d %0d", $dimensions(r), $unpacked_dimensions(r));
  end
endmodule

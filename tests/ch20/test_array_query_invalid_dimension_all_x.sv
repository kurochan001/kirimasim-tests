/*
:name: test_array_query_invalid_dimension_all_x
:description: an array query function returns 'x when the dimension asked for is out of range, and an in-range dimension returns the bound (IEEE 1800-2023 Section 20.7)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7 21.2.1.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_array_query_invalid_dimension_all_x.expected
*/
// IEEE 1800-2023 §20.7: the array query functions return integer. If the
// dimension argument is out of range, they return 'x, an integer with all
// bits x, which %h shows as xxxxxxxx (§21.2.1.3). A real, shortreal or
// event is outside the domain of these functions (§20.7), so none is
// passed to them.
// The line asks a 2-dimensional array for dimensions 0, 3 and 5 and for the
// in-range dimension 2 as a contrast.

module test_array_query_invalid_dimension_all_x;
  logic [3:0] v4 [2];

  initial begin
    $display("range: %h %h %h %h in range: %0d %0d", $left(v4, 0), $right(v4, 3), $size(v4, 5),
             $high(v4, 3), $left(v4, 2), $size(v4, 1));
  end
endmodule

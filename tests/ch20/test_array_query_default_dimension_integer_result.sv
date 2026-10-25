/*
:name: test_array_query_default_dimension_integer_result
:description: the array query functions take a variable, an expression or a data type, use dimension 1 when the dimension is left out, and return an integer, a signed 32-bit 4-state value (IEEE 1800-2023 Section 20.7)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_array_query_default_dimension_integer_result.expected
*/
// IEEE 1800-2023 §20.7: the first argument of an array query function is an
// array or integral expression or a data type; $left, $right, $low, $high,
// $increment and $size take an optional dimension, which is 1 by default;
// the result is of type integer, which is signed, 32 bits wide and 4-state.
// Line 1 compares each of the six functions without a dimension with the same
// call with dimension 1 on ram, a [3:0] unpacked array of a [15:8] packed
// type; a wrong default would compare a dimension 1 bound (3 or 0) with a
// dimension 2 bound (15 or 8). Line 2 queries the variable, the type itself,
// the element expression ram[0], dimension 2 and $dimensions of the type.
// Line 3 shows that the result is 32 bits, signed ($increment of an
// ascending range is below 0) and 4-state (an out-of-range dimension gives
// x, which a 2-state int could not hold).
// Icarus Verilog 13.0 rejects the typedef name word_t as an argument.

module test_array_query_default_dimension_integer_result;
  typedef logic [15:8] word_t;
  word_t ram [3:0];
  bit [0:5] up;

  initial begin
    $display("default: %0d %0d %0d %0d %0d %0d", $left(ram) == $left(ram, 1),
             $right(ram) == $right(ram, 1), $low(ram) == $low(ram, 1),
             $high(ram) == $high(ram, 1), $increment(ram) == $increment(ram, 1),
             $size(ram) == $size(ram, 1));
    $display("args: %0d %0d %0d %0d %0d", $left(ram), $left(word_t), $right(ram[0]),
             $size(ram, 2), $dimensions(word_t));
    $display("integer: bits=%0d negative=%0d unknown=%0d", $bits($size(ram)), $increment(up) < 0,
             $isunknown($left(ram, 3)));
  end
endmodule

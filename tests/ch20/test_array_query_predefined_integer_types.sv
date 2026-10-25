/*
:name: test_array_query_predefined_integer_types
:description: the array query functions treat byte, shortint, int, longint, integer and time as a packed array with the single dimension [n-1:0] (IEEE 1800-2023 Section 20.7)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_query_predefined_integer_types.expected
*/
// IEEE 1800-2023 §20.7: an integer type with a predefined width, byte,
// shortint, int, longint, integer or time, is treated by the array query
// functions as a packed array with one dimension [n-1:0], n being its width.
// So $left is n-1, $right and $low are 0, $high is n-1, $size is n,
// $increment is 1 and $dimensions is 1, whether the argument is the type or
// a variable of it. In an unpacked array of int this packed dimension is
// dimension 2.
// Each line prints $left, $right, $low, $high, $size, $increment and
// $dimensions of a variable, then $left and $size of the type itself.
// Icarus Verilog 13.0 rejects a built-in type name as the argument.

module test_array_query_predefined_integer_types;
  byte b;
  shortint s;
  int i;
  longint l;
  integer g;
  time t;
  int ia [3];

  initial begin
    $display("byte %0d %0d %0d %0d %0d %0d %0d type %0d %0d", $left(b), $right(b), $low(b),
             $high(b), $size(b), $increment(b), $dimensions(b), $left(byte), $size(byte));
    $display("shortint %0d %0d %0d %0d %0d %0d %0d type %0d %0d", $left(s), $right(s), $low(s),
             $high(s), $size(s), $increment(s), $dimensions(s), $left(shortint), $size(shortint));
    $display("int %0d %0d %0d %0d %0d %0d %0d type %0d %0d", $left(i), $right(i), $low(i),
             $high(i), $size(i), $increment(i), $dimensions(i), $left(int), $size(int));
    $display("longint %0d %0d %0d %0d %0d %0d %0d type %0d %0d", $left(l), $right(l), $low(l),
             $high(l), $size(l), $increment(l), $dimensions(l), $left(longint), $size(longint));
    $display("integer %0d %0d %0d %0d %0d %0d %0d type %0d %0d", $left(g), $right(g), $low(g),
             $high(g), $size(g), $increment(g), $dimensions(g), $left(integer), $size(integer));
    $display("time %0d %0d %0d %0d %0d %0d %0d type %0d %0d", $left(t), $right(t), $low(t),
             $high(t), $size(t), $increment(t), $dimensions(t), $left(time), $size(time));
    $display("int array: dims %0d dim2 %0d %0d %0d", $dimensions(ia), $left(ia, 2),
             $right(ia, 2), $size(ia, 2));
  end
endmodule

/*
:name: test_typed_pattern_expression_self_determined
:description: an assignment pattern prefixed with a type name has that type on its own, so it can be an operand of a concatenation, of $bits, of arithmetic, of a comparison and of a cast, and its value is that of a variable of the type initialized by the pattern (IEEE 1800-2023 Section 10.9)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_typed_pattern_expression_self_determined.expected
*/
// IEEE 1800-2023 §10.9: an assignment pattern alone has no self-determined
// type and can only be one side of an assignment-like context. Prefixed with
// a type name it becomes an assignment pattern expression, which has that
// type as its self-determined type and can be used elsewhere in expressions.
// On a right-hand side it gives the value that a variable of the type would
// hold if it were initialized with the pattern.
//
// n3_t is a packed array of three 4-bit nibbles (12 bits), pt_t a packed
// structure of two bytes (x is the upper one), arr3_t an unpacked int array.
//   {n3_t'{5, 6, 7}, 4'h8}       12 + 4 bits: 5678
//   $bits of the two patterns    12 and 16
//   pt_t'{x: 3, y: 4} + 1        16'h0304 + 1 = 773
//   pt_t'{default: 8'hff}        ffff
//   a3 == arr3_t'{1, 2, 3} / '{1, 2, 4}   1 and 0
//   shortint'(pt_t'{x: 8'hff, y: 8'hfe}) 16'hfffe read as signed: -2

module test_typed_pattern_expression_self_determined;
  typedef bit [2:0][3:0] n3_t;
  typedef struct packed {
    byte x;
    byte y;
  } pt_t;
  typedef int arr3_t[0:2];

  arr3_t a3 = '{1, 2, 3};

  initial begin
    $display("concat: %h", {n3_t'{4'h5, 4'h6, 4'h7}, 4'h8});
    $display("bits: %0d %0d", $bits(n3_t'{1, 2, 3}), $bits(pt_t'{x: 1, y: 2}));
    $display("arith: %0d", pt_t'{x: 3, y: 4} + 1);
    $display("default: %h", pt_t'{default: 8'hff});
    $display("compare: %0d %0d", a3 == arr3_t'{1, 2, 3}, a3 == arr3_t'{1, 2, 4});
    $display("cast: %0d", shortint'(pt_t'{x: 8'hff, y: 8'hfe}));
  end
endmodule

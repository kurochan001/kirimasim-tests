/*
:name: test_typename_predefined_width_distinct
:description: $typename gives different strings for a type with a predefined width and a matching simple bit vector type with an explicit range, while a typedef of a type gives the string of that type (IEEE 1800-2023 Section 20.6.1)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.1 6.22.1 6.23
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_typename_predefined_width_distinct.expected
*/
// IEEE 1800-2023 §20.6.1: $typename resolves typedefs to the types they name,
// like type matching does, but unlike type matching it tells a simple bit
// vector type with a predefined width apart from one with a range written
// by the user. §6.22.1 e): byte matches bit signed [7:0], int matches
// bit signed [31:0] and integer matches logic signed [31:0]. §6.23: two type
// references compare equal exactly when their types match.
// For each pair the test prints whether type() compares them equal and
// whether their $typename strings are equal. The pairs of a predefined-width
// type and its explicit-range equivalent match but have different names;
// a typedef of byte, and a typedef of bit signed [7:0] against that type
// written out, match and have the same name.
// Neither simulator follows the clauses here: Icarus Verilog 13.0 rejects
// type() in a comparison, and in release 5.052 of the Verilator tool a type
// with a predefined width does not compare equal to its matching type.

module test_typename_predefined_width_distinct;
  typedef bit signed [7:0] sbyte_t;
  typedef byte byte_t;
  byte by;
  byte_t bt;
  sbyte_t sb;
  bit signed [7:0] sv8;
  int i32;
  bit signed [31:0] bv32;
  integer ig;
  logic signed [31:0] lv32;

  initial begin
    $display("byte/bit signed[7:0]: match=%0d same=%0d", type(by) == type(sb),
             $typename(by) == $typename(sb));
    $display("int/bit signed[31:0]: match=%0d same=%0d", type(i32) == type(bv32),
             $typename(i32) == $typename(bv32));
    $display("integer/logic signed[31:0]: match=%0d same=%0d", type(ig) == type(lv32),
             $typename(ig) == $typename(lv32));
    $display("byte/typedef byte: match=%0d same=%0d", type(by) == type(bt),
             $typename(by) == $typename(bt));
    $display("typedef/written out: match=%0d same=%0d", type(sb) == type(sv8),
             $typename(sb) == $typename(sv8));
  end
endmodule

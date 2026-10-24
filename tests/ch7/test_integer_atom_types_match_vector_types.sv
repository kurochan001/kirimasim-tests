/*
:name: test_integer_atom_types_match_vector_types
:description: each integer type with a predefined width n matches the packed vector type with the same state, sign and the single dimension [n-1:0], and no vector type that differs in one of them (IEEE 1800-2023 Section 7.4.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1 6.22.1 6.23
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_integer_atom_types_match_vector_types.expected
*/
// IEEE 1800-2023 §7.4.1: an integer type with a predefined width n is not a
// packed array, but it matches (§6.22.1) a packed array type with the single
// dimension [n-1:0]. By §6.22.1 rule e, such a vector type matches when it has
// the same width, is 2-state or 4-state like the integer type, has the same
// signedness and has the range [n-1:0]. A comparison of type references
// (§6.23) is 1 for matching types and 0 otherwise. Each integer type is
// compared with its matching vector type, and byte also with vectors that
// differ only in range, sign or state; int is compared with a 4-state vector.
// Icarus Verilog 13.0 does not support type references. In Verilator 5.052 an
// integer type matches no vector type, so every comparison below gives 0.

module test_integer_atom_types_match_vector_types;
  localparam bit BYTE_M = type(byte) == type(bit signed [7:0]);
  localparam bit BYTE_RANGE = type(byte) == type(bit signed [0:7]);
  localparam bit BYTE_SIGN = type(byte) == type(bit [7:0]);
  localparam bit BYTE_STATE = type(byte) == type(logic signed [7:0]);
  localparam bit SHORTINT_M = type(shortint) == type(bit signed [15:0]);
  localparam bit INT_M = type(int) == type(bit signed [31:0]);
  localparam bit INT_STATE = type(int) == type(logic signed [31:0]);
  localparam bit LONGINT_M = type(longint) == type(bit signed [63:0]);
  localparam bit INTEGER_M = type(integer) == type(logic signed [31:0]);
  localparam bit TIME_M = type(time) == type(logic [63:0]);

  initial begin
    $display("byte: [7:0]=%0d [0:7]=%0d unsigned=%0d 4-state=%0d",
             BYTE_M, BYTE_RANGE, BYTE_SIGN, BYTE_STATE);
    $display("shortint=%0d int=%0d int vs 4-state=%0d longint=%0d",
             SHORTINT_M, INT_M, INT_STATE, LONGINT_M);
    $display("integer=%0d time=%0d", INTEGER_M, TIME_M);
  end
endmodule

/*
:name: test_enum_encoding_value_changed_by_cast
:description: an enum name whose value expression changes under the cast to the base type gets the cast value, through a change of signedness, a sign extension or a truncation, and the next name without a value is that value plus one (IEEE 1800-2023 Section 6.19)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19 6.24.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_encoding_value_changed_by_cast.expected
*/
// IEEE 1800-2023 §6.19: the value expression of an enum name is evaluated as
// if cast to the base type of the enum; the value after the cast is the value
// of the name and the one that the next name without a value increments. The
// cast is an error only when it truncates and drops bits that are not zero
// (unsigned base) or not equal to the sign bit of the result (signed base).
// §6.24.1: the cast gives the value that a variable of the base type holds
// after being assigned the expression. The expressions are parameters, not
// sized literals, so their widths may differ from the base:
// - the byte -56 for an unsigned 8-bit base becomes 200, and the next two
//   names are 201 and 202;
// - the same byte for an unsigned 12-bit base is sign-extended, since the
//   byte is signed, to 12'hfc8 = 4040, and the next name is 4041;
// - the int unsigned 32'hffff_fff0 for a byte base is truncated to 8'hf0,
//   whose sign bit equals the dropped ones, so it is -16, then -15;
// - the int -3 for an int unsigned base becomes 4294967293, then 4294967294;
// - as a control, the unsigned 8'hc8 for a shortint base is zero-extended,
//   since the expression is unsigned, and stays 200, then 201.
// A tool that kept the value of the expression, extended by the signedness
// of the base, or counted on from the value before the cast would print
// other values, or reject a next name as out of range.
// Oracle checks: Icarus Verilog 13.0 rejects U12_A as a negative value and
// S8_A as too large; the 5.054 release of Verilator zero-extends the byte
// for the 12-bit base and prints 200 201 on the second line, although it
// sign-extends the same byte in an assignment or a cast to a 12-bit type.

module test_enum_encoding_value_changed_by_cast;
  localparam byte PB = -56;
  localparam int unsigned PU = 32'hffff_fff0;
  localparam int PN = -3;
  localparam bit [7:0] PV = 8'hc8;

  typedef enum bit [7:0] {U8_A = PB, U8_B, U8_C} u8_t;
  typedef enum bit [11:0] {U12_A = PB, U12_B} u12_t;
  typedef enum byte {S8_A = PU, S8_B} s8_t;
  typedef enum int unsigned {UI_A = PN, UI_B} ui_t;
  typedef enum shortint {SH_A = PV, SH_B} sh_t;

  initial begin
    $display("bit [7:0] base: %0d %0d %0d", U8_A, U8_B, U8_C);
    $display("bit [11:0] base: %0d %0d", U12_A, U12_B);
    $display("byte base: %0d %0d", S8_A, S8_B);
    $display("int unsigned base: %0d %0d", UI_A, UI_B);
    $display("shortint base: %0d %0d", SH_A, SH_B);
  end
endmodule

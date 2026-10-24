/*
:name: test_enum_encoding_cast_to_base
:description: the value expression of an enum name is evaluated as if cast to the base type, so it gets the width and sign of the base, and the next name increments the cast value (IEEE 1800-2023 Section 6.19)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19 6.24.1 11.6.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_encoding_cast_to_base.expected
*/
// IEEE 1800-2023 §6.19: the value expression of an enum name is evaluated in
// the context of a cast to the base type, and the value after the cast is the
// value of the name and the start of the automatic increment. A cast to a
// type gives the value a variable of that type gets when assigned the
// expression (§6.24.1), so the expression is evaluated with the width of the
// base (§11.6.1): 4'hf + 4'h1 is 16 for a 5-bit base, not the 4-bit 0. The
// unsigned sized literal 8'hff becomes -1 for a signed 8-bit base and 8'd200
// becomes -56; the signed literal 4'sb1110 becomes 14 for an unsigned 4-bit
// base. Each following name without a value is one more than the cast value.
// Icarus Verilog 13.0 evaluates 4'hf + 4'h1 with its own 4-bit width and
// gives Q=0 R=1; the cast to the 5-bit base gives 16 and 17.

module test_enum_encoding_cast_to_base;
  typedef enum bit [4:0] {Q = 4'hf + 4'h1, R} wide_t;
  typedef enum bit signed [7:0] {S1 = 8'hff, S2} sgn_t;
  typedef enum bit signed [7:0] {S3 = 8'd200, S4} sgn2_t;
  typedef enum bit [3:0] {U1 = 4'sb1110, U2} uns_t;
  int i;

  initial begin
    $display("5-bit base: Q=%0d R=%0d", Q, R);
    $display("signed base: S1=%0d S2=%0d S3=%0d S4=%0d", S1, S2, S3, S4);
    i = U1;
    $display("unsigned base: U1=%0d U2=%0d int=%0d", U1, U2, i);
    i = S1;
    $display("signed to int: %0d", i);
  end
endmodule

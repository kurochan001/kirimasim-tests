/*
:name: test_illegal_enum_signed_value_out_of_range
:description: For a signed 4-bit enum base, the value 8 is out of range, since the bits cut off do not equal the sign bit of the result (IEEE 1800-2023 Section 6.19)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.19
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the value 8 of the name HI does not fit the signed 4-bit base: the cast keeps 4'b1000, whose sign bit 1 differs from the discarded zero bits
:expected_stderr_regex: test_illegal_enum_signed_value_out_of_range\.sv:24:
*/
// IEEE 1800-2023 §6.19: the value is cast to the base type; for a signed
// base it is out of range, and an error, when the cast cuts off bits and any
// of them differs from the sign bit of the result. 8 cast to logic signed
// [3:0] keeps 4'b1000 (sign bit 1) and cuts off zero bits. LO = -7 is in
// range: its cut-off bits are all 1 like its sign bit. No other name has the
// value -8 that the truncated 8 would have, so only the range is in error.
// Icarus Verilog 13.0 rejects HI as too large. Verilator 5.052 accepts the
// design and truncates 8 to -8.

module test_illegal_enum_signed_value_out_of_range;
  typedef enum logic signed [3:0] {LO = -7, HI = 8} e_t;    // illegal: 8 is out of range
  e_t e;
  initial e = LO;
endmodule

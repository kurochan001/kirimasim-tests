/*
:name: test_illegal_packed_array_of_real
:description: A packed array cannot have real elements (IEEE 1800-2023 Section 7.4.1)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.4.1 6.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a packed dimension is given to a type defined as real
:expected_stderr_regex: test_illegal_packed_array_of_real\.sv:25\b
*/
// IEEE 1800-2023 §7.4.1: packed arrays can be made only of the single-bit
// types, enumerated types, and other packed arrays and packed structures; real
// (§6.12) is none of these. The packed dimension is given to a type name of
// real.
// Icarus Verilog 13.0 writes the line of this error without a colon after it,
// so :expected_stderr_regex: ends the line number with a word boundary. The
// design is accepted by Verilator 5.052 (docs/simulator-differences.md).

typedef real test_illegal_packed_array_of_real_t;

module test_illegal_packed_array_of_real;
  test_illegal_packed_array_of_real_t [1:0] pair;   // illegal
  initial $display("declared");
endmodule

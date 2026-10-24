/*
:name: test_illegal_int_packed_dimension
:description: an integer type with a predefined width, here int, cannot be declared with packed array dimensions (IEEE 1800-2023 Section 7.4.1)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.4.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a packed dimension is declared on int, an integer type with a predefined width
:expected_stderr_regex: test_illegal_int_packed_dimension\.sv:19:
*/
// IEEE 1800-2023 §7.4.1: byte, shortint, int, longint, integer and time have
// predefined widths and shall not have packed array dimensions declared. The
// same packed dimension on a logic vector is legal, as the other line shows.

module test_illegal_int_packed_dimension;
  int [1:0] pair;   // illegal: packed dimension on int
  logic [1:0][31:0] ok_pair;
endmodule

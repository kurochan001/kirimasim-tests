/*
:name: test_illegal_packed_dimension_single_size
:description: a packed dimension needs a range with two bounds; a single size such as [8] is allowed only for unpacked dimensions (IEEE 1800-2023 Section 7.4.1)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.4.1 7.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a packed dimension is given as a single size [8] instead of a range
:expected_stderr_regex: test_illegal_packed_dimension_single_size\.sv:22:
*/
// IEEE 1800-2023 §7.4.1: each packed dimension is a range of two constant
// expressions, so a packed dimension cannot be declared with only one number.
// §7.4.2 allows that form for an unpacked dimension, where [8] means [0:7];
// the declaration of mem uses it legally, and that of byte_ok uses a packed
// range with a negative bound, which is also legal.
// Icarus Verilog 13.0 accepts the single-size packed dimension.

module test_illegal_packed_dimension_single_size;
  bit [8] octet;   // illegal: packed dimension with a single size
  bit mem [8];
  bit [-1:6] byte_ok;
endmodule

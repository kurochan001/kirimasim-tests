/*
:name: test_illegal_assoc_shortreal_index
:description: a shortreal cannot be the index type of an associative array
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.8.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the index type of the associative array is shortreal
:expected_stderr_regex: test_illegal_assoc_shortreal_index\.sv:21:
*/
// IEEE 1800-2023 7.8.5: an associative index type cannot be real or
// shortreal, and the prohibition applies recursively to a type that contains
// either. Here the index type itself is shortreal, so the declaration of aa
// is illegal. Icarus Verilog 13.0 rejects the declaration; Verilator 5.052
// accepts it and promotes shortreal to real.

module test_illegal_assoc_shortreal_index;
  int aa[shortreal];   // illegal: shortreal index type
endmodule

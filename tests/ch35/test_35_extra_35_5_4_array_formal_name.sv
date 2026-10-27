/*
:name: test_35_extra_35_5_4_array_formal_name
:description: An array formal argument without a name cannot separate its packed dimension from its unpacked dimension, so the import declaration is rejected (IEEE 1800-2023 Section 35.5.4)
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.5.4 35.5.6.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an array formal argument has no name between its packed and unpacked dimensions
:expected_stderr_regex: test_35_extra_35_5_4_array_formal_name\.sv:21:
*/
// IEEE 1800-2023 §35.5.4: "A formal argument name is required to separate the
// packed and the unpacked dimensions of an array." The import below declares
// a packed dimension [3] and an open unpacked dimension [] with no name
// between them, so the declaration is not legal. The expected error is a
// syntax error at the second bracket of the declaration.

module test_35_extra_35_5_4_array_formal_name;
  import "DPI-C" function void c_unnamed(input int [3][]);
endmodule

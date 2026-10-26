/*
:name: test_illegal_bits_dynamic_type_id
:description: $bits is applied directly to a dynamically sized type identifier (IEEE 1800-2023 Section 20.6.2)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: $bits is called directly on the dynamic array type int[]
:expected_stderr_regex: test_illegal_bits_dynamic_type_id\.sv:18:
*/
// $bits shall not be used directly with a dynamically sized data type
// identifier, because the number of bits of such a type is not fixed.

module test_illegal_bits_dynamic_type_id;
  localparam int W = $bits(int[]);   // illegal: dynamic type identifier
  initial $display(W);
endmodule

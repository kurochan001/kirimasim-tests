/*
:name: test_illegal_continuous_assign_to_dynamic_element
:description: An element of a dynamically sized array cannot be written by a continuous assignment (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.21 7.5 10.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the continuous assignment writes da[0], an element of a dynamic array
:expected_stderr_regex: test_illegal_continuous_assign_to_dynamic_element\.sv:23:
*/
// IEEE 1800-2023 §6.21: elements of dynamically sized array variables shall
// not be written with continuous assignments (§10.3). da is a dynamic array
// (§7.5).
// The array is not otherwise written, so that nothing else writes da.
// Icarus Verilog 13.0 stops with a failed assertion of its compiler.

module test_illegal_continuous_assign_to_dynamic_element;
  int da[];
  int src = 5;
  assign da[0] = src;    // illegal: continuous assignment to a dynamic array element
endmodule

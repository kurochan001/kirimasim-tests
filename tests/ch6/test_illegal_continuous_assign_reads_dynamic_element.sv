/*
:name: test_illegal_continuous_assign_reads_dynamic_element
:description: A continuous assignment cannot reference an element of a dynamic array, since such references are limited to procedural blocks (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.21 7.5 10.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the continuous assignment to w reads da[0], an element of a dynamic array, outside a procedural block
:expected_stderr_regex: test_illegal_continuous_assign_reads_dynamic_element\.sv:23:
*/
// IEEE 1800-2023 §6.21: references to automatic variables and to elements
// or members of dynamic variables shall be limited to procedural blocks.
// The continuous assignment (§10.3) reads an element of the dynamic array da
// (§7.5).
// Neither Icarus Verilog 13.0 nor Verilator 5.052 rejects the design.

module test_illegal_continuous_assign_reads_dynamic_element;
  int da[];
  wire [31:0] w;
  assign w = da[0];    // illegal: dynamic array element outside a procedure
  initial da = new[2];
endmodule

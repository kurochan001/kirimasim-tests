/*
:name: test_illegal_dynamic_array_element_continuous
:description: An element of a dynamic array cannot be driven by a continuous assignment (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.21 7.5 10.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a continuous assignment drives an element of a dynamic array
:expected_stderr_regex: test_illegal_dynamic_array_element_continuous\.sv:25:
*/
// IEEE 1800-2023 §6.21: elements of dynamically sized array variables (§7.5)
// shall not be written with continuous assignments (§10.3), as the element can
// cease to exist.
// Icarus Verilog 13.0 stops on an internal assertion
// (docs/simulator-differences.md).

`timescale 1ns/1ns

module test_illegal_dynamic_array_element_continuous;
  int values[];
  logic [31:0] in = 5;
  assign values[0] = in;   // illegal: continuous assignment to a dynamic array element
  initial begin
    values = new[2];
    #1 $display("values[0]=%0d", values[0]);
  end
endmodule

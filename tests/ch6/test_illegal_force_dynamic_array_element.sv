/*
:name: test_illegal_force_dynamic_array_element
:description: An element of a dynamically sized array cannot be written by a procedural continuous assignment such as force (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.21 7.5 10.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the force statement writes da[0], an element of a dynamic array
:expected_stderr_regex: test_illegal_force_dynamic_array_element\.sv:25:
*/
// IEEE 1800-2023 §6.21: elements of dynamically sized array variables shall
// not be written with procedural continuous assignments; force (§10.6.2) is
// one. da is a dynamic array (§7.5).
// On this line Verilator 5.052 stops with an internal error for an
// unsupported force target, and Icarus Verilog 13.0 only says it cannot
// force an array word; neither is a diagnosis of the rule.

module test_illegal_force_dynamic_array_element;
  int da[];
  initial begin
    da = new[1];
    force da[0] = 5;    // illegal: procedural continuous assignment to an element
  end
endmodule

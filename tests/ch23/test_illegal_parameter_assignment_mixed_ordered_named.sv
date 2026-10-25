/*
:name: test_illegal_parameter_assignment_mixed_ordered_named
:description: The parameter value assignment of an instance is entirely by ordered list or entirely by name, so it cannot mix the two (IEEE 1800-2023 Section 23.10.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.10.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance u gives A by position and B by name in one parameter value assignment
:expected_stderr_regex: test_illegal_parameter_assignment_mixed_ordered_named\.sv:24:
*/
// IEEE 1800-2023 §23.10.2: the two forms of instance parameter value
// assignment, by ordered list and by name, shall not be mixed; the
// assignments to one instance are all by order or all by name. u gives the
// first parameter by position and the second by name.
// The design is accepted by Verilator 5.052.

module parameter_mixed_leaf #(parameter int A = 1, parameter int B = 2) ();
endmodule

module test_illegal_parameter_assignment_mixed_ordered_named;
  parameter_mixed_leaf #(5, .B(6)) u();   // illegal
endmodule

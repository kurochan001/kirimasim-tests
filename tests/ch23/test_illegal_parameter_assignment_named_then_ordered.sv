/*
:name: test_illegal_parameter_assignment_named_then_ordered
:description: One instance cannot mix parameter assignments by name and by order, also when the named one comes first, while different instances of a module can each use one form (IEEE 1800-2023 Section 23.10.2.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.10.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the parameter value assignment of u gives A by name and then a value by position
:expected_stderr_regex: test_illegal_parameter_assignment_named_then_ordered\.sv:27:
*/
// IEEE 1800-2023 §23.10.2.2: it is legal for one module to instantiate a
// module several times with different forms of parameter redefinition, such
// as by_order by ordered list and by_name by name, but one instance shall not
// mix redefinitions by order and by name. u names A first and then gives a
// value by position.
// Oracle checks: the 5.052 release of Verilator accepts the design.

module pnt_leaf #(parameter int A = 1, parameter int B = 2) ();
endmodule

module test_illegal_parameter_assignment_named_then_ordered;
  pnt_leaf #(3, 4) by_order ();
  pnt_leaf #(.B(5)) by_name ();
  pnt_leaf #(.A(5), 6) u ();   // illegal: by name, then by order
endmodule

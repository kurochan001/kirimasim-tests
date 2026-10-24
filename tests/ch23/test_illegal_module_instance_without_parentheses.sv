/*
:name: test_illegal_module_instance_without_parentheses
:description: Every module instantiation needs parentheses, even for a module without ports, so an instance written without them is an error (IEEE 1800-2023 Section 23.3.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance u2 of the portless module noparen_leaf has no parentheses
:expected_stderr_regex: test_illegal_module_instance_without_parentheses\.sv:25:
*/
// IEEE 1800-2023 §23.3.2: the parentheses shall be required on all module
// instantiations, even when the instantiated module does not have ports
// (hierarchical_instance in Syntax 23-6). The instance u1 of the portless
// module noparen_leaf has empty parentheses and is legal; u2 has none.

module noparen_leaf;
  initial $display("%m");
endmodule

module test_illegal_module_instance_without_parentheses;
  noparen_leaf u1();
  noparen_leaf u2;  // illegal: no parentheses
endmodule

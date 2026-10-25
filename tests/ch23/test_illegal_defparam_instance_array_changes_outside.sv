/*
:name: test_illegal_defparam_instance_array_changes_outside
:description: A defparam statement inside an instance of an array of instances cannot change a parameter of an instance outside that hierarchy (IEEE 1800-2023 Section 23.10.1)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.10.1 23.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the defparam in the module of the arrayed instances arr names the parameter P of the instance outside, which is not inside arr
:expected_stderr_regex: test_illegal_defparam_instance_array_changes_outside\.sv:27:
*/
// IEEE 1800-2023 §23.10.1: a defparam statement in or under an instance of
// an array of instances (§23.3.2) shall not change a parameter outside that
// hierarchy. Each element of arr holds the defparam of its module, which
// names the parameter P of the instance outside of the top module. The
// design is otherwise legal: the same defparam placed in the top module
// would be.
// Icarus Verilog 13.0 and Verilator 5.052 accept this design.

module defparam_array_outside_leaf;
  parameter int P = 0;
endmodule

module defparam_array_outside_elem;
  defparam test_illegal_defparam_instance_array_changes_outside.outside.P = 5;   // illegal
endmodule

module test_illegal_defparam_instance_array_changes_outside;
  defparam_array_outside_leaf outside();
  defparam_array_outside_elem arr[1:0] ();
endmodule

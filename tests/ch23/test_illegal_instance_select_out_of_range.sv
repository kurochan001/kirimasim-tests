/*
:name: test_illegal_instance_select_out_of_range
:description: An instance select in a hierarchical name has to evaluate to a legal index of the instance array (IEEE 1800-2023 Section 23.6)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.6 23.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the hierarchical name arr[2].v selects index 2 of the instance array arr[0:1], which has no such instance
:expected_stderr_regex: test_illegal_instance_select_out_of_range\.sv:26:
*/
// IEEE 1800-2023 §23.6: the instance select of an instance array in a
// hierarchical name shall evaluate to one of the legal index values of
// the array. arr has the indices 0 and 1 (§23.3.2), so arr[2].v names no
// instance; arr[1].v would be legal.

module instance_select_range_elem;
  logic [3:0] v = 4'h3;
endmodule

module test_illegal_instance_select_out_of_range;
  instance_select_range_elem arr[0:1] ();

  initial #1 $display("v=%h", arr[2].v);   // illegal
endmodule

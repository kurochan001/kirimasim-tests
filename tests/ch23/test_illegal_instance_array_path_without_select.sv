/*
:name: test_illegal_instance_array_path_without_select
:description: A name of an instance array that is not the last element of a hierarchical name needs an instance select (IEEE 1800-2023 Section 23.6)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.6 23.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the hierarchical name arr.v uses the instance array arr as a path element without an instance select
:expected_stderr_regex: test_illegal_instance_array_path_without_select\.sv:28:
*/
// IEEE 1800-2023 §23.6: a name of an instance array or of a loop generate
// block in a hierarchical name may be followed by an instance select, a
// constant expression in brackets, and when the name is not the last
// element of the path the select is required. arr is an array of two
// instances (§23.3.2); arr.v leaves out the select, where arr[0].v would
// be legal.

module instance_array_path_elem;
  logic [3:0] v = 4'h3;
endmodule

module test_illegal_instance_array_path_without_select;
  instance_array_path_elem arr[0:1] ();

  initial #1 $display("v=%h", arr.v);   // illegal
endmodule

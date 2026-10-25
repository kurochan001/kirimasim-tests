/*
:name: test_illegal_array_query_dynamic_type_name
:description: an array query function cannot be applied directly to the name of a dynamically sized type (IEEE 1800-2023 Section 20.7)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: $size is applied to dyn_t, a typedef of a dynamic array type, instead of to a variable of that type
:expected_stderr_regex: test_illegal_array_query_dynamic_type_name\.sv:27:
*/
// IEEE 1800-2023 §20.7: it is an error to use the array query functions
// directly on a dynamically sized type identifier, since such a type has no
// size of its own. dyn_t names a dynamic array type; the query of the
// variable v of that type on the line before is legal.
// Icarus Verilog 13.0 reports an error on the illegal line only because it
// does not accept any type name there, and release 5.052 of the Verilator
// tool stops there with an internal error, so neither counts.

module test_illegal_array_query_dynamic_type_name;
  typedef int dyn_t [];
  dyn_t v;

  initial $display("%0d", $size(v));
  initial $display("%0d", $size(dyn_t));   // illegal: dyn_t is a dynamic array type
endmodule

/*
:name: test_illegal_interface_class_nested_class
:description: an interface class cannot contain a nested class (IEEE 1800-2023 Section 8.26)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the interface class bad_if declares the nested class inner_c
:expected_stderr_regex: test_illegal_interface_class_nested_class\.sv:(27|29):
*/
// IEEE 1800-2023 §8.26: an interface class shall contain only pure virtual
// methods, type declarations and parameter declarations; constraint blocks,
// covergroups and nested classes are not allowed in it. good_if has one of
// each allowed kind, which is legal. bad_if also contains a nested class;
// a tool can report the member or the interface class that holds it.
// Icarus Verilog 13.0 does not support interface classes, and Verilator 5.052
// accepts the design.

interface class good_if #(parameter int N = 2);
  typedef bit [N-1:0] word_t;
  pure virtual function word_t get();
endclass

interface class bad_if;   // (or reported here)
  pure virtual function int size();
  class inner_c;   // illegal: a nested class in an interface class
  endclass
endclass

module test_illegal_interface_class_nested_class;
  initial $display("done");
endmodule

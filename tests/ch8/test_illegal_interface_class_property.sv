/*
:name: test_illegal_interface_class_property
:description: an interface class cannot contain a property (IEEE 1800-2023 Section 8.26)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the interface class bad_if declares the property count
:expected_stderr_regex: test_illegal_interface_class_property\.sv:(26|28):
*/
// IEEE 1800-2023 §8.26: an interface class shall contain only pure virtual
// methods, type declarations and parameter declarations; constraint blocks,
// covergroups and nested classes are not allowed in it. good_if has one of
// each allowed kind, which is legal. bad_if also contains a property;
// a tool can report the member or the interface class that holds it.
// Icarus Verilog 13.0 does not support interface classes.

interface class good_if #(parameter int N = 2);
  typedef bit [N-1:0] word_t;
  pure virtual function word_t get();
endclass

interface class bad_if;   // (or reported here)
  pure virtual function int size();
  int count;   // illegal: a property in an interface class
endclass

module test_illegal_interface_class_property;
  initial $display("done");
endmodule

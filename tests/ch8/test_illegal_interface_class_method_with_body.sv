/*
:name: test_illegal_interface_class_method_with_body
:description: an interface class cannot contain a method with a body (IEEE 1800-2023 Section 8.26)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the interface class bad_if declares the virtual method twice with a body, not a pure virtual method
:expected_stderr_regex: test_illegal_interface_class_method_with_body\.sv:(26|28|29):
*/
// IEEE 1800-2023 §8.26: an interface class shall contain only pure virtual
// methods, type declarations and parameter declarations; constraint blocks,
// covergroups and nested classes are not allowed in it. good_if has one of
// each allowed kind, which is legal. bad_if also contains a method with a body;
// a tool can report the member, the start of its body or its interface class.
// Icarus Verilog 13.0 does not support interface classes.

interface class good_if #(parameter int N = 2);
  typedef bit [N-1:0] word_t;
  pure virtual function word_t get();
endclass

interface class bad_if;   // (or reported here)
  pure virtual function int size();
  virtual function int twice(int x);   // illegal: not a pure virtual method
    return 2 * x;   // (or here, at the body: its methods are prototypes, A.1.9)
  endfunction
endclass

module test_illegal_interface_class_method_with_body;
  initial $display("done");
endmodule

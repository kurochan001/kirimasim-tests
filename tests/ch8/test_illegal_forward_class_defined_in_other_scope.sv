/*
:name: test_illegal_forward_class_defined_in_other_scope
:description: the class of a forward class declaration has to be defined in the same local scope (IEEE 1800-2023 Section 8.27)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.27 6.18
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the forward declaration of node_c in the module is resolved only by a class node_c in the generate block g
:expected_stderr_regex: test_illegal_forward_class_defined_in_other_scope\.sv:(24|26):
*/
// IEEE 1800-2023 §8.27: as for other forward typedefs (6.18), the actual
// class of a forward class declaration shall be defined within the same
// local scope or generate block. pair_c is declared forward and defined in
// the module, which is legal; node_c is declared forward in the module but
// defined only inside the generate block g, another scope. A tool can report
// the forward declaration or the variable of the incomplete type.
// Icarus Verilog 13.0 stops with a failed internal assertion.

module test_illegal_forward_class_defined_in_other_scope;
  typedef class pair_c;
  typedef class node_c;   // illegal: never defined in this scope
  pair_c p;
  node_c head;   // (or reported here)

  class pair_c;
    int a = 1;
  endclass

  if (1) begin : g
    class node_c;
      int v;
    endclass
  end

  initial begin
    p = new;
    $display("%0d", p.a);
  end
endmodule

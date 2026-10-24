/*
:name: test_illegal_generate_interface_block_gate
:description: Inside an interface a generate block can hold only interface items, so a gate instance in it is illegal, while a continuous assignment is legal (IEEE 1800-2023 Section 27.3)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the selected generate block of the interface gib_if instantiates a buf gate
:expected_stderr_regex: test_illegal_generate_interface_block_gate\.sv:27:
*/
// IEEE 1800-2023 §27.3, footnote 35 of Syntax 27-1: within an interface
// declaration a generate_item shall only be an interface_or_generate_item,
// which is a module_common_item or an extern subroutine declaration. A gate
// instantiation is a module_or_generate_item and not a module_common_item.
// The generate block of gib_if declares a net and drives it with a
// continuous assignment, both legal, and also instantiates a buf.
// The 5.052 release of Verilator accepts the design.

interface gib_if #(parameter bit WITH_BUF = 1'b1);
  logic a = 1'b1;
  if (WITH_BUF) begin : g
    wire y, z;
    assign y = a;
    buf b1 (z, a);   // illegal: a gate instance in an interface generate block
  end
endinterface

module test_illegal_generate_interface_block_gate;
  gib_if u ();
  initial #1 $display("%b", u.g.y);
endmodule

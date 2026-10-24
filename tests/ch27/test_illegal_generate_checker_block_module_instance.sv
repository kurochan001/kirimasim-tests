/*
:name: test_illegal_generate_checker_block_module_instance
:description: Inside a checker a generate block can hold only checker items, so a module instance in it is illegal, while a checker variable is legal (IEEE 1800-2023 Section 27.3)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the generate block of the checker gcm_chk instantiates the module gcm_leaf
:expected_stderr_regex: test_illegal_generate_checker_block_module_instance\.sv:28:
*/
// IEEE 1800-2023 §27.3, footnote 35 of Syntax 27-1: within a checker
// declaration a generate_item shall only be a checker_or_generate_item. A
// module instantiation is a module_or_generate_item and is not among the
// checker items. The generate block of gcm_chk declares a checker variable,
// which is a legal checker item, and also instantiates gcm_leaf.
// Icarus Verilog 13.0 does not support checkers (syntax error at the
// checker header), which does not count.

module gcm_leaf;
endmodule

checker gcm_chk(logic a);
  if (1) begin : g
    logic seen = 1'b0;
    gcm_leaf u_leaf ();   // illegal: a module instance in a checker generate block
  end
endchecker

module test_illegal_generate_checker_block_module_instance;
  logic a = 1'b1;
  gcm_chk c (a);
  initial $display("top");
endmodule

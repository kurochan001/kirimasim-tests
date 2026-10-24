/*
:name: test_illegal_program_generate_for_module_instance
:description: A module instance is as illegal in a loop generate block of a program as it is directly in the program (IEEE 1800-2023 Section 24.3)
:tags: ch24
:type: elaboration
:lrm: 1800-2023 24.3 27.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the block of a loop generate construct in the program pgf_p instantiates the module pgf_leaf
:expected_stderr_regex: test_illegal_program_generate_for_module_instance\.sv:29:
*/
// IEEE 1800-2023 §24.3: a program shall not contain instances of modules,
// and, by footnote 5 of Syntax 24-1, a program_generate_item shall not contain
// any item that would be illegal in the program outside the generate item.
// The loop generate construct (27.4) of pgf_p makes two blocks g_l[0] and
// g_l[1]; each declares a variable, which is legal, and instantiates the
// module pgf_leaf, which is not.
// Oracle checks: the 5.052 release of Verilator accepts the design.

module pgf_leaf;
  initial $display("leaf %m");
endmodule

program pgf_p;
  for (genvar i = 0; i < 2; i++) begin : g_l
    int v = i;
    pgf_leaf u_leaf ();   // illegal: module instance in a program generate block
  end
  initial $display("program");
endprogram

module test_illegal_program_generate_for_module_instance;
  pgf_p u_p ();
endmodule

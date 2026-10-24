/*
:name: test_illegal_generate_block_name_of_variable
:description: A named block of a conditional generate construct cannot have the name of another declaration in the same scope, even when the block is not selected, while its alternatives can share a name of their own (IEEE 1800-2023 Section 27.5)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the unselected case-generate block named mode has the name of the variable mode of the module
:expected_stderr_regex: test_illegal_generate_block_name_of_variable\.sv:32:
*/
// IEEE 1800-2023 §27.5: a named generate block shall not have the same name
// as any other declaration in the same scope, even if the block is not
// selected for instantiation. The case-generate construct selects the block
// sel for W = 8; its two other alternatives are named sel and mode. The
// alternatives named sel share one name, which is legal; the alternative
// named mode, never selected, has the name of the variable mode.
// The 5.052 release of Verilator rejects the clash only as "Unsupported in
// C", which does not count.

module test_illegal_generate_block_name_of_variable #(parameter int W = 8);
  int mode = 0;
  case (W)
    8: begin : sel
      int n = 8;
    end
    16: begin : sel
      int n = 16;
    end
    default: begin : mode   // illegal: mode is the name of a variable here
      int n = 0;
    end
  endcase
  initial $display("%0d %0d", sel.n, mode);
endmodule

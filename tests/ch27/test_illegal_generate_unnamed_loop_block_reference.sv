/*
:name: test_illegal_generate_unnamed_loop_block_reference
:description: the declarations in an unnamed loop generate block cannot be reached by a hierarchical name from outside that block (IEEE 1800-2023 Section 27.4)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.4 27.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initial procedure of the module reaches variable x of the unnamed loop block by the name genblk1[1].x
:expected_stderr_regex: test_illegal_generate_unnamed_loop_block_reference\.sv:32:
*/
// IEEE 1800-2023 §27.4: the declarations in an unnamed loop generate block
// can be referenced by hierarchical names only from within the hierarchy
// that the block instantiates. §27.6: genblk<n> is the name of such a block
// for external interfaces, not a name for hierarchical names in the source.
// Inside each block, the procedure reaches y of the named if generate
// block inner by a hierarchical name, which is legal. The initial
// procedure of the module reaches x through genblk1[1], which is illegal.
// Icarus Verilog 13.0 and the 5.052 release of Verilator both accept it.

module test_illegal_generate_unnamed_loop_block_reference;
  for (genvar i = 0; i < 2; i++) begin
    int x = i;
    if (1) begin : inner
      int y = i + 1;
    end
    initial #1 x = inner.y;
  end

  initial #2 $display("%0d", genblk1[1].x);   // illegal
endmodule

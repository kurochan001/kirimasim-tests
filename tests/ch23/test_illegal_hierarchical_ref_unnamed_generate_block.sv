/*
:name: test_illegal_hierarchical_ref_unnamed_generate_block
:description: Objects declared in an unnamed generate block can be referenced by hierarchical names only from within the block, so a reference from outside through the external name genblk1 is not permitted (IEEE 1800-2023 Section 23.6)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.6 27.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initial procedure outside the unnamed generate block reads its variable y through the hierarchical name genblk1.y
:expected_stderr_regex: test_illegal_hierarchical_ref_unnamed_generate_block\.sv:27:
*/
// IEEE 1800-2023 §23.6: objects declared in unnamed generate blocks can
// be referenced by hierarchical names only from within the block and the
// hierarchy that it instantiates. §27.6: the name genblk1 that such a
// block gets is for external interfaces and cannot be used in a
// hierarchical name. The initial procedure is outside the block and reads
// genblk1.y; naming the block would make the reference legal.
// Icarus Verilog 13.0 and Verilator 5.052 accept the design.

module test_illegal_hierarchical_ref_unnamed_generate_block;
  if (1) begin
    logic [3:0] y = 4'h5;
  end

  initial #1 $display("y=%h", genblk1.y);   // illegal
endmodule

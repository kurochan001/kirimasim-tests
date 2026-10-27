/*
:name: test_ch9_extra_unnamed_block_scope
:description: a variable declared in an unnamed sequential block belongs to the unnamed scope of that block and cannot be reached by a hierarchical name (IEEE 1800-2023 Section 9.3.4)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.3.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: inner is declared in an unnamed block, whose scope has no name that a hierarchical reference could use
:expected_stderr_regex: test_ch9_extra_unnamed_block_scope\.sv:32:
*/
// IEEE 1800-2023 §9.3.4: a block that directly contains a block item
// declaration has a scope of its own. When the block is unnamed that scope
// is unnamed too, so its declarations have no hierarchical name: there is no
// path with which another scope could reach inner. The variable is usable
// inside the block, as the first display shows, and the reference
// test_ch9_extra_unnamed_block_scope.inner from the enclosing initial
// procedure names no declaration and is an elaboration error.
//
// The unnamed block is a begin-end block without a block name that declares
// inner before its statement. A named block would be reachable instead; the
// design is rejected because this block has no name.

module test_ch9_extra_unnamed_block_scope;
  initial begin
    begin
      int inner = 7;
      $display("inner=%0d", inner);
    end
    $display("hidden=%0d", test_ch9_extra_unnamed_block_scope.inner);
  end
endmodule

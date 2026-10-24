/*
:name: test_illegal_unnamed_block_variable_hierarchical
:description: A variable declared in an unnamed block cannot be reached by a hierarchical name through the enclosing named block (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.21 9.3.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the hierarchical name outer.v refers to v, which is declared in an unnamed block nested in outer
:expected_stderr_regex: test_illegal_unnamed_block_variable_hierarchical\.sv:26:
*/
// IEEE 1800-2023 §6.21: variables may be declared in unnamed blocks; they
// are visible in that block and its nested blocks, but they shall not be
// accessed by hierarchical name. v is declared in an unnamed block inside
// the named block outer (§9.3.4); the use of v inside the unnamed block is
// legal, and the later reference outer.v is the error.

module test_illegal_unnamed_block_variable_hierarchical;
  initial begin : outer
    begin
      int v;
      v = 4;
    end
    $display("%0d", outer.v);    // illegal: v is in an unnamed block
  end
endmodule

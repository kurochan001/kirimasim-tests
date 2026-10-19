/*
:name: test_disable_named_block_with_forks
:description: disable ends a named block started by fork...join_none, and a block's disable ends the processes forked inside it (IEEE 1800-2023 Section 9.6.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.2 9.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_disable_named_block_with_forks.expected
*/
// IEEE 1800-2023 §9.6.2: disable ends a named block wherever it runs, also
// when the block is a process that fork...join_none started (9.3.2) and the
// disable statement is in the parent. Disabling a named block also ends
// every activity started inside it: when one branch of a fork in the block
// disables the block, the other branch ends too, and the statement after
// the join does not run.

module test_disable_named_block_with_forks;
  int child_done = 0, sibling_done = 0, after_join = 0;

  initial begin
    fork
      begin : child
        #100 child_done = 1;
      end
    join_none
    #13 disable child;
  end

  initial begin : outer
    fork
      #5 disable outer;
      #100 sibling_done = 1;
    join
    after_join = 1;
  end

  initial begin
    #200;
    $display("child_done=%0d sibling_done=%0d after_join=%0d", child_done, sibling_done,
             after_join);
  end
endmodule

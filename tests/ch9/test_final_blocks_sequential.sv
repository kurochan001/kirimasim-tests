/*
:name: test_final_blocks_sequential
:description: final procedures run after the last time step, in one sequential process and in an arbitrary but deterministic order, so their updates are ordered without fixing which block runs first (IEEE 1800-2023 9.2.3, 9.5)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.3 9.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_final_blocks_sequential.expected
*/
// IEEE 1800-2023 §9.2.3: final procedures execute at the end of simulation,
// after all other processes, in an arbitrary but deterministic sequential
// order, and no source order between them is specified. §9.5 lists final
// execution among the kinds of execution thread. The test has two final
// blocks that each increment the same variable and print it. Both see the
// value the last initial assigned (2), the two increments are not lost, and
// the printed counts are 1 then 2 whichever block runs first, so the expected
// output fixes the sequential order of the updates but not the identity of
// the block. Two blocks that ran as independent concurrent processes could
// both print 1.

module test_final_blocks_sequential;
  int count = 0;
  int state = 0;

  initial begin
    #5 state = 1;
    #5 state = 2;
  end

  final begin
    count++;
    $display("final count=%0d state=%0d", count, state);
  end

  final begin
    count++;
    $display("final count=%0d state=%0d", count, state);
  end
endmodule

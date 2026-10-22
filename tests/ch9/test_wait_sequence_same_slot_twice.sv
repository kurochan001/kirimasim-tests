/*
:name: test_wait_sequence_same_slot_twice
:description: A second wait on an already triggered sequence completes in the same time step (IEEE 1800-2023 Section 9.4.4)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.4 16.13.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_wait_sequence_same_slot_twice.expected
*/
// IEEE 1800-2023 9.4.4 16.13.5: Sequence triggered remains true through the
// rest of its ending time slot, so two consecutive level sensitive waits need
// no second match.
// Oracle checks: Icarus Verilog 13.0 does not build this case. The 5.052
// release does not build this case.

`timescale 1ns/1ns
module test_wait_sequence_same_slot_twice;
  bit clk, a = 1, b;
  always #5 clk = ~clk;
  sequence pair; @(posedge clk) a ##1 b; endsequence
  initial begin
    wait(pair.triggered);
    $display("first=%0d", $time);
    wait(pair.triggered);
    $display("second=%0d", $time);
    $finish;
  end
  initial begin #10 a = 0; b = 1; end
endmodule

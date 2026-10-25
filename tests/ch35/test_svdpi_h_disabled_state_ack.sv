/*
:name: test_svdpi_h_disabled_state_ack
:description: svIsDisabledState returns 0 in an imported task that is not disabled and 1 after an export it called returned because a block around the import was disabled, and the import acknowledges the disable with svAckDisabledState before it returns (IEEE 1800-2023 Section 35.3.2, I.3, 35.9, H.9.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 I.3 35.9 H.9.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_svdpi_h_disabled_state_ack.c
:expected_stdout: @test_svdpi_h_disabled_state_ack.expected
*/
// IEEE 1800-2023 §35.3.2: the C layer of DPI is the one Annex I lists.
// I.3, H.9.3 and 35.9: svIsDisabledState returns 1 when the execution thread
// that calls it is in the disabled state and 0 when it is not, and an
// imported function that is in the disabled state calls svAckDisabledState
// before it returns, which is how it tells the simulator that it took part in
// the disable protocol.
//
// The imported task c_work is called from the block worker and itself calls
// the exported task sv_wait, which waits 10ns. At 5ns the other initial block
// disables worker, so sv_wait returns 1 because the import above it was
// disabled; c_work then sees svIsDisabledState of 1 where it saw 0 before the
// call, acknowledges the disable, and returns. The display after the call in
// worker must not run, because the disable takes effect when the import
// acknowledges it.
//
// Icarus Verilog 13.0 has no DPI. Verilator 5.052 does not support timing
// controls in exported tasks, so :oracle: names no simulator.

`timescale 1ns/1ns

module test_svdpi_h_disabled_state_ack;
  import "DPI-C" context task c_work();
  export "DPI-C" task sv_wait;

  task sv_wait();
    #10;
  endtask

  initial begin : worker
    $display("%0d: before the import", $time);
    c_work();
    $display("%0d: after the import, which must not run", $time);
  end

  initial begin
    #5 disable worker;
  end
endmodule

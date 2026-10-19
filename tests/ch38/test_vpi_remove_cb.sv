/*
:name: test_vpi_remove_cb
:description: vpi_remove_cb returns 1 and the removed callback is not called again: a value change callback stops reporting changes, and a time callback removed before its time never runs (IEEE 1800-2023 Section 38.39)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.39 38.36.1 38.36.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_remove_cb.c
:expected_stdout: @test_vpi_remove_cb.expected
*/
// IEEE 1800-2023 §38.39: vpi_remove_cb removes a callback placed with
// vpi_register_cb and returns 1 on success; the handle is then no longer
// valid. At time 0, $vt_watch places a cbValueChange callback on r (38.36.1)
// and a cbAfterDelay callback for time 30 (38.36.2). r changes at 10; at 15
// $vt_unwatch removes both callbacks, so the change of r at 20 and time 30
// pass without a callback.

`timescale 1ns/1ns

module test_vpi_remove_cb;
  logic [3:0] r = 4'd0;

  initial begin
    $vt_watch;
    #10 r = 4'd1;
    #5 $vt_unwatch;
    #5 r = 4'd2;
    #20 $display("%0d: r = %0d", $time, r);
  end
endmodule

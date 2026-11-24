/*
:name: test_vpi_restart_preserves_restart_callbacks_and_drops_value_change
:description: Restart retains its action callbacks and removes a previously registered value-change callback
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.3 37.2.2 D.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_restart_preserves_restart_callbacks_and_drops_value_change.expected
:expected_exit: 0
:vpi_c: @test_vpi_restart_preserves_restart_callbacks_and_drops_value_change.c
:files: checkpoint_fixtures/request_restore_once.svh
*/
`timescale 1ns/1ns
module test_vpi_restart_preserves_restart_callbacks_and_drops_value_change;
  `include "request_restore_once.svh"

  int watched;

  initial begin
    #1;
    $probe_restart_callbacks(0, watched);
    watched = 11;
    #3 $save("restart-callbacks.chk");
    #4;
    if (first_restore_request()) $restart("restart-callbacks.chk");
    $probe_restart_callbacks(1, watched);
    watched = 22;
    #1;
    $probe_restart_callbacks(2, watched);
    $finish(0);
  end
endmodule

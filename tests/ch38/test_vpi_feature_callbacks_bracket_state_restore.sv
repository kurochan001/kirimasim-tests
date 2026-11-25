/*
:name: test_vpi_feature_callbacks_bracket_state_restore
:description: Save and restart feature callbacks bracket an observed restore of simulation time and a variable
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.3 D.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_feature_callbacks_bracket_state_restore.expected
:expected_exit: 0
:vpi_c: @test_vpi_feature_callbacks_bracket_state_restore.c
:files: checkpoint_fixtures/request_restore_once.svh
*/
`timescale 1ns/1ns

module test_vpi_feature_callbacks_bracket_state_restore;
  `include "request_restore_once.svh"

  int value = 11;

  initial begin
    #2 value = 29;
    #1 $save("callback-phases.chk");
    #2;
    if (first_restore_request()) begin
      value = 77;
      #2 $display("restart request time=%0d value=%0d", $time, value);
      $restart("callback-phases.chk");
    end
    $display("resume value=%0d saved-time-range=%0d", value, $time >= 3 && $time < 7);
    $finish(0);
  end
endmodule

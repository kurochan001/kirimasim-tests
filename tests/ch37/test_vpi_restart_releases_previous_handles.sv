/*
:name: test_vpi_restart_releases_previous_handles
:description: Restart retires old object and callback handles except its start and end callbacks
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.2.2 38.36.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_vpi_restart_releases_previous_handles
:expected_stdout: @test_vpi_restart_releases_previous_handles.expected
:expected_exit: 0
:vpi_c: @test_vpi_restart_releases_previous_handles.c
:incdirs: ../ch38/checkpoint_fixtures
*/
`timescale 1ns/1ns
module test_vpi_restart_releases_previous_handles;
  `include "request_restore_once.svh"

  logic [7:0] watched = 0;
  logic [7:0] pending = 0;

  initial begin
    #1 $observe_restart_handles(0, watched, pending);
    watched = 11;
    #3 $save("handle-lifetime.chk");
    #4;
    if (first_restore_request()) begin
      watched = 17;
      #1;
      if (!$test$plusargs("no_restart")) $restart("handle-lifetime.chk");
    end
    $display("restored value=%0d", watched);
    $observe_restart_handles(1, watched, pending);
    watched = 22;
    #1 $observe_restart_handles(2, watched, pending);
    $finish(0);
  end
endmodule

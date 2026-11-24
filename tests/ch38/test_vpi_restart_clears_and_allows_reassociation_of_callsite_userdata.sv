/*
:name: test_vpi_restart_clears_and_allows_reassociation_of_callsite_userdata
:description: Restart clears saved callsite userdata and accepts reassociation at the same callsite
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.14 38.33 D.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_restart_clears_and_allows_reassociation_of_callsite_userdata.expected
:expected_exit: 0
:vpi_c: @test_vpi_restart_clears_and_allows_reassociation_of_callsite_userdata.c
:files: checkpoint_fixtures/request_restore_once.svh
*/
`timescale 1ns/1ns
module test_vpi_restart_clears_and_allows_reassociation_of_callsite_userdata;
  `include "request_restore_once.svh"

  task inspect(input int stage);
    $probe_restart_userdata(stage);
  endtask

  initial begin
    #1 inspect(0);
    #1 inspect(1);
    #2 $save("restart-userdata.chk");
    #4;
    if (first_restore_request()) $restart("restart-userdata.chk");
    inspect(2);
    #1 inspect(3);
    $finish(0);
  end
endmodule

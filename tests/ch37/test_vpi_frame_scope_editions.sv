/*
:name: test_vpi_frame_scope_editions
:description: A module initial procedure has a frame that is the parent of an automatic task frame
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.43
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_frame_scope_editions.c
:expected_stdout: @test_vpi_frame_scope_editions.expected
*/
module test_vpi_frame_scope_editions;
  task automatic child;
    int task_value = 31;
    $vt_task_frame_version;
  endtask

  initial begin
    $vt_procedure_frame_version;
    child();
    $finish(0);
  end
endmodule

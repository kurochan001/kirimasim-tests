/*
:name: test_vpi_unresolved_task_callback_supplies_called_name
:description: An unresolved user system task delivers its called name to the VPI action callback
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.3 5.6.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_unresolved_task_callback_supplies_called_name.c
:expected_stdout: @test_vpi_unresolved_task_callback_supplies_called_name.expected
*/
module test_vpi_unresolved_task_callback_supplies_called_name;
  initial begin
    $public_regression_unregistered_probe;
    $finish(0);
  end
endmodule

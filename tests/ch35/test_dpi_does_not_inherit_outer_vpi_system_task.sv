/*
:name: test_dpi_does_not_inherit_outer_vpi_system_task
:description: A nested DPI import has its own boundary inside a VPI system task
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.3 H.9.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_does_not_inherit_outer_vpi_system_task.c
:expected_stdout: @test_dpi_does_not_inherit_outer_vpi_system_task.expected
*/
module test_dpi_does_not_inherit_outer_vpi_system_task;
  import "DPI-C" context function int probe_system_task_access();
  export "DPI-C" function call_dpi_from_system_task;

  function int call_dpi_from_system_task();
    return probe_system_task_access();
  endfunction

  initial begin
    int observed;
    observed = probe_system_task_access();
    $display("plain DPI call=%0d error=%0d", observed & 1, observed >> 1);
    $check_vpi_task_boundary($test$plusargs("observe_nested_dpi"));
    $finish(0);
  end
endmodule

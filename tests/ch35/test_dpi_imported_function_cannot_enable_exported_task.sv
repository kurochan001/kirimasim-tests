/*
:name: test_dpi_imported_function_cannot_enable_exported_task
:description: A timed exported task can be enabled by an imported context task only
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dpi_imported_function_cannot_enable_exported_task.expected
:dpi_c: @dpi_exported_task_invocation_fixture.c
:files: dpi_exported_task_invocation_fixture.sv
:defines: DPI_FIXTURE_TIMED_ACTION
:expected_stderr_regex: (?im:^[^\n]*(?:error|invalid|illegal)[^\n]*(?:DPI|export)[^\n]*br_sv_action[^\n]*function)
*/
`timescale 1ns/1ns

module test_dpi_imported_function_cannot_enable_exported_task;
  dpi_exported_task_invocation_fixture fixture();
endmodule

/*
:name: test_vpi_compatibility_scope_and_migration
:description: Verify the design scope of a VPI compatibility mode and migrate a real array query
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.12.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_vpi_compatibility_scope_and_migration
:files: vpi_mode_partition/legacy.sv vpi_mode_partition/modern.sv vpi_mode_partition/compatible_top.sv
:vpi_c: @test_vpi_compatibility_scope_and_migration.c
:expected_stdout: @test_vpi_compatibility_scope_and_migration.expected
*/
`timescale 1ns/1ns

module test_vpi_compatibility_scope_and_migration;
  vpi_mode_legacy_partition legacy();
  vpi_mode_modern_partition modern();

  initial #1 $display("hdl legacy=%0d modern=%0d", legacy.scalar, modern.element.value);
endmodule

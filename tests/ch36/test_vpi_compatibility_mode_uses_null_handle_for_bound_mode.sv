/*
:name: test_vpi_compatibility_mode_uses_null_handle_for_bound_mode
:description: The null-object compatibility-mode property reports the compile-bound VPI mode
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.12.2.1 M.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_compatibility_mode_uses_null_handle_for_bound_mode.expected
:vpi_c: @test_vpi_compatibility_mode_uses_null_handle_for_bound_mode.c
*/
module test_vpi_compatibility_mode_uses_null_handle_for_bound_mode;
  initial #1 $vt_compat_property;
endmodule

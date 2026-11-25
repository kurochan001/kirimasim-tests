/*
:name: test_vpi_public_header_shares_one_legacy_mode_with_callbacks
:description: A legacy VPI mode is shared by the application and its start callback
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.12.2.1 L.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: vpi_mode_selection/callback.c
:vpi_c: @vpi_mode_selection/application.c
:expected_stdout: @test_vpi_public_header_shares_one_legacy_mode_with_callbacks.expected
*/
module test_vpi_public_header_shares_one_legacy_mode_with_callbacks;
  initial #1 $display("legacy mode body");
endmodule

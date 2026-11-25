/*
:name: test_preprocessor_line_emission_modes_preserve_manual_origin
:description: An authored line directive supplies logical source locations when preprocessed output includes or omits line records
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.12 22.13 22.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: line_emission/payload.svh
:expected_stdout: @test_preprocessor_line_emission_modes_preserve_manual_origin.expected
*/
// tools/run_preprocessor_effects.py preprocesses this source in both
// output modes, then simulates the two generated sources.
`include "payload.svh"
module test_preprocessor_line_emission_modes_preserve_manual_origin;
  initial begin
`line 700 "reviewed_origin.sv" 0
    $display("logical=%s:%0d imported=%0d", `__FILE__, `__LINE__, `VT_IMPORT_VALUE);
    $display("logical=%s:%0d", `__FILE__, `__LINE__);
  end
endmodule

/*
:name: test_protect_reset_stops_encoding_state_at_file_boundary
:description: A protect reset at the end of one input file restores the defaults for the following file
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.31.2 22.11.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:compilation_unit: single
:top_module: protect_file_reset_top
:expected_stdout: protect reset files compiled
:files: pragma_reset_inputs/encoding_group.sv pragma_reset_inputs/next_group.sv
*/

module protect_file_reset_top;
  initial $display("protect reset files compiled");
endmodule

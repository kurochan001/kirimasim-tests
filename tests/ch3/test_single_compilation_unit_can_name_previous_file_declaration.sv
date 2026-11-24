/*
:name: test_single_compilation_unit_can_name_previous_file_declaration
:description: The explicit compilation-unit name finds a prior file declaration in single-unit mode
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.12.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_single_compilation_unit_can_name_previous_file_declaration.expected
:files: unit_visibility_provider.sv
:args: --compilation-unit=single
*/
module test_single_compilation_unit_can_name_previous_file_declaration;
  initial $display("previous declaration=%0d", $unit::mode_visible_value);
endmodule

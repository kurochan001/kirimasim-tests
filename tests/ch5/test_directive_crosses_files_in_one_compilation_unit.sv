/*
:name: test_directive_crosses_files_in_one_compilation_unit
:description: A macro defined in an earlier source file remains visible in another file of the same compilation unit
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.6.4 3.12.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: compilation_unit_directive_provider.sv
:compilation_unit: single
:expected_stdout: @test_directive_crosses_files_in_one_compilation_unit.expected
*/
`timescale 100ps/10ps
module test_directive_crosses_files_in_one_compilation_unit;
  directive_provider provider();
`ifdef COMPILATION_UNIT_DIRECTIVE_MARKER
  localparam int visible_marker = `COMPILATION_UNIT_DIRECTIVE_MARKER;
`else
  localparam int visible_marker = -1;
`endif
  initial #1 $display("consumer marker=%0d", visible_marker);
endmodule

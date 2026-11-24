/*
:name: test_per_file_compilation_does_not_share_macro_or_default_nettype
:description: Macro and default nettype directives stop at their compilation-unit boundary
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.12.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_per_file_compilation_does_not_share_macro_or_default_nettype.expected
:files: directive_unit_provider.sv
:args: --compilation-unit=per-file
*/
`timescale 1ns/1ns
module test_per_file_compilation_does_not_share_macro_or_default_nettype;
  localparam int FLAG =
`ifdef PROVIDER_FEATURE_FLAG
      `PROVIDER_FEATURE_FLAG;
`else
      0;
`endif
  directive_unit_provider source_unit(.value(implicit_result));

  initial #1 $display("macro=%0d port=%b", FLAG, implicit_result);
endmodule

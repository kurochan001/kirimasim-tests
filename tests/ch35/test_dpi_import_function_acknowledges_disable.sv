/*
:name: test_dpi_import_function_acknowledges_disable
:description: An imported DPI function acknowledges a disable before returning to its caller
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.9 I.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @dpi_function_disable_ack/application.cpp
:files: dpi_function_disable_ack/drive.svh
:expected_stdout: @test_dpi_import_function_acknowledges_disable.expected
*/
`timescale 1ns/1ns

module test_dpi_import_function_acknowledges_disable;
  localparam int OMIT_ACK = 0;
  `include "drive.svh"
endmodule

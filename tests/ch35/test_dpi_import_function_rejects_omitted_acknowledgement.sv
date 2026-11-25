/*
:name: test_dpi_import_function_rejects_omitted_acknowledgement
:description: A disabled DPI import function returning without acknowledgement requires a fatal error
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.9 I.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @dpi_function_disable_ack/application.cpp
:files: dpi_function_disable_ack/drive.svh
:expected_stdout: @test_dpi_import_function_rejects_omitted_acknowledgement.expected
:expected_exit: nonzero
:expected_stderr_regex: (?im)^(?=[^\n]*\b(?:fatal|error)\b)(?=[^\n]*\bdpi\b)(?=[^\n]*disabl)(?=[^\n]*acknowledg)[^\n]+
*/
`timescale 1ns/1ns

module test_dpi_import_function_rejects_omitted_acknowledgement;
  localparam int OMIT_ACK = 1;
  `include "drive.svh"
endmodule

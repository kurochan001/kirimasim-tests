/*
:name: test_vpi_readonly_callback_rejects_immediate_write
:description: A read only synchronization callback cannot write a variable
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.2 38.34
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_readonly_callback_rejects_immediate_write.expected
:vpi_c: @test_vpi_readonly_callback_rejects_immediate_write.c
:expected_stderr_regex: (?i:\b(?:put|write)\b[^\n]*\bread[ -]?only\b|\bread[ -]?only\b[^\n]*\b(?:put|write)\b)
*/
`timescale 1ns/1ns
module test_vpi_readonly_callback_rejects_immediate_write;
  logic [7:0] sample = 37;

  initial #3 $display("after=%0d", sample);
endmodule

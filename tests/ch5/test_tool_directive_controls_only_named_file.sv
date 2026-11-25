/*
:name: test_tool_directive_controls_only_named_file
:description: A Verilator configuration directive suppresses a truncation diagnostic for one named source file
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.6.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: directive_filter/waive.vlt
:expected_stdout: @test_tool_directive_controls_only_named_file.expected
*/
// tools/run_verilator_directive_extension.py checks this exact source
// with and without the tool directive and under another filename.
`timescale 1ns/1ns
module test_tool_directive_controls_only_named_file;
  logic [7:0] source;
  wire [3:0] selected;
  assign selected = source;

  initial begin
    source = 8'ha5;
    #1 $display("selected=%h", selected);
    source = 8'h3b;
    #1 $display("selected=%h", selected);
  end
endmodule

/*
:name: test_single_pass_library_loading
:description: Bind one library cell under explicit and on-demand source loading
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.5.1 33.5.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_single_pass_library_loading
:files: single_pass_library/phase_needed.v single_pass_library/phase_unused.v single_pass_library/phase_bad.txt
:expected_stdout: @test_single_pass_library_loading.expected
*/
`timescale 1ns/1ns
module test_single_pass_library_loading;
  wire [7:0] value;
  phase_needed #(.VALUE(19)) dut(value);
  initial begin
    #1 $display("bound library value=%0d", value);
    $finish(0);
  end
endmodule

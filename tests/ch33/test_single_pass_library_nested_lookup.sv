/*
:name: test_single_pass_library_nested_lookup
:description: Find transitive library cells and propagate a signal across them
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.5.1 33.5.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_single_pass_library_nested_lookup
:files: single_pass_library/phase_parent.v single_pass_library/phase_child.v single_pass_library/phase_unused.v single_pass_library/phase_bad.txt
:expected_stdout: @test_single_pass_library_nested_lookup.expected
*/
`timescale 1ns/1ns
module test_single_pass_library_nested_lookup;
  reg [7:0] stimulus = 8'd3;
  wire [7:0] observed;
  phase_parent dut(stimulus, observed);
  initial begin
    #1 $display("nested input=%0d output=%0d", stimulus, observed);
    stimulus = 8'd12;
    #1 $display("nested input=%0d output=%0d", stimulus, observed);
    $finish(0);
  end
endmodule

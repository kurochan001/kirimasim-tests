/*
:name: test_annex_library_map_source_boundary
:description: Source files and library maps have distinct top level syntax
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.3.1 A A.1.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_annex_library_map_source_boundary
:files: annex_map_boundary/empty.map annex_map_boundary/null_item.map annex_map_boundary/library_item.map annex_map_boundary/provider.sv
:expected_stdout: @test_annex_library_map_source_boundary.expected
*/
`timescale 1ns/1ns
module test_annex_library_map_source_boundary;
  localparam int SOURCE_MARKER = 23;
  int marker = SOURCE_MARKER;
  initial begin
    #1 $display("source grammar marker=%0d", marker);
    $finish(0);
  end
endmodule

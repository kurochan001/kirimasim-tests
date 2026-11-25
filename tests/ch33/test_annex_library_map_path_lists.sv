/*
:name: test_annex_library_map_path_lists
:description: Library map declarations accept comma separated paths and a single include target
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.3.1 A A.1.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_annex_library_map_path_lists
:files: annex_library_map/layout.map annex_library_map/parts/extra.map annex_library_map/plain.sv annex_library_map/computed.sv annex_library_map/parts/extra.sv
:incdirs: annex_library_map/first_include annex_library_map/second_include
:expected_stdout: @test_annex_library_map_path_lists.expected
*/
`timescale 1ns/1ns
module test_annex_library_map_path_lists;
  wire [7:0] plain_value, computed_value, extra_value;
  annex_plain plain_cell(plain_value);
  annex_computed computed_cell(computed_value);
  annex_extra extra_cell(extra_value);
  initial begin
    #1 $display("library paths=%0d,%0d included=%0d",
                plain_value, computed_value, extra_value);
    $finish(0);
  end
endmodule

/*
:name: test_nested_library_map_includes_restore_the_containing_directory
:description: Nested library map includes preserve the containing directory of each declaration
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: nested_map_config
:expected_exit: 0
:expected_stdout: @test_nested_library_map_includes_restore_the_containing_directory.expected
:files: libmap_nested/maps/root.map libmap_nested/maps/supplier/sub.map libmap_nested/maps/supplier/nested/content.map libmap_nested/fallback.sv libmap_nested/maps/source/root.sv libmap_nested/maps/supplier/source/middle.sv libmap_nested/maps/supplier/source/inner.sv
*/
`timescale 1ns/1ns
module nested_map_top;
  wire [7:0] root_value, middle_value, inner_value;
  root_cell root_binding(root_value);
  middle_cell middle_binding(middle_value);
  inner_cell inner_binding(inner_value);
  initial #1 $display("root=%0d middle=%0d inner=%0d", root_value, middle_value, inner_value);
endmodule

config nested_map_config;
  design work.nested_map_top;
  instance nested_map_top.root_binding use rootLib.root_cell;
  instance nested_map_top.middle_binding use middleLib.middle_cell;
  instance nested_map_top.inner_binding use innerLib.inner_cell;
endconfig

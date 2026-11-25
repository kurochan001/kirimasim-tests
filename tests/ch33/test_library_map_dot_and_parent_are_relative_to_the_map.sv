/*
:name: test_library_map_dot_and_parent_are_relative_to_the_map
:description: Current and parent directory paths resolve from the library map file
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: relative_config
:expected_exit: 0
:expected_stdout: @libmap_relative/bindings.expected
:files: libmap_relative/maps/deep/provider.map libmap_relative/top.svh libmap_relative/fallback.sv libmap_relative/maps/deep/cells/location.sv libmap_relative/maps/up/location.sv
*/
`include "top.svh"

config relative_config;
  design work.relative_top;
  instance relative_top.at_local use localLib.local_cell;
  instance relative_top.at_parent use parentLib.parent_cell;
endconfig

/*
:name: test_library_map_hierarchical_wildcard_matches_zero_and_nested_directories
:description: A hierarchical library path wildcard matches zero directories and nested directories
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: wildcard_config
:expected_exit: 0
:expected_stdout: @test_library_map_hierarchical_wildcard_matches_zero_and_nested_directories.expected
:files: libmap_wildcards/hierarchy.map libmap_wildcards/top.svh libmap_wildcards/tree/cellname.sv libmap_wildcards/tree/child/deeper/cellABname_extra.sv libmap_wildcards/tree/cellAname.sv libmap_wildcards/tree/child/deeper/cellBname_extra.sv
*/
`include "top.svh"

config wildcard_config;
  design work.wildcard_top;
  instance wildcard_top.shallow use selectedLib.shallow_cell;
  instance wildcard_top.deep use selectedLib.deep_cell;
endconfig

/*
:name: test_illegal_library_map_contains_a_module_declaration
:description: A source-language module declaration is rejected in a library map
:tags: ch33
:type: elaboration
:lrm: 1800-2023 33.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: map_contents_config
:should_fail_because: a module is not a library map item
:expected_stderr_regex: invalid_contents\.map:3:
:files: libmap_invalid_contents/invalid_contents.map libmap_invalid_contents/units.sv
*/
module map_contents_top;
  valid_map_cell selected();
endmodule

config map_contents_config;
  design work.map_contents_top;
  instance map_contents_top.selected use validLib.valid_map_cell;
endconfig

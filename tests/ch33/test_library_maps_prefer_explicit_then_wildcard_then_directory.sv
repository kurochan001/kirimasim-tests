/*
:name: test_library_maps_prefer_explicit_then_wildcard_then_directory
:description: Two library maps give explicit filenames priority over wildcard filenames and directories
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.3.1.1 33.3.3 3.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: priority_config
:expected_exit: 0
:expected_stdout: @test_library_maps_prefer_explicit_then_wildcard_then_directory.expected
:files: libmap_priority/directory.map libmap_priority/filenames.map libmap_priority/fallback.sv libmap_priority/inputs/pick.sv libmap_priority/inputs/middle.sv libmap_priority/inputs/base.v
*/
`timescale 1ns/1ns
module priority_top;
  wire [7:0] a, b, c;
  selected explicit_choice(a);
  masked wildcard_choice(b);
  remnant directory_choice(c);
  initial #1 $display("explicit=%0d wildcard=%0d directory=%0d", a, b, c);
endmodule

config priority_config;
  design work.priority_top;
  instance priority_top.explicit_choice use explicitFile.selected;
  instance priority_top.wildcard_choice use maskLib.masked;
  instance priority_top.directory_choice use broad.remnant;
endconfig

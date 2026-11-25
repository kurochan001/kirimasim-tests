/*
:name: test_library_map_star_stays_within_a_path_component
:description: A library map star matches empty and longer filename tails within one path component
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: star_config
:expected_exit: 0
:expected_stdout: @test_library_map_star_stays_within_a_path_component.expected
:files: libmap_star/name.map libmap_star/cells/marker_component/wrong.sv libmap_star/cells/marker.sv libmap_star/cells/marker_extra.sv
*/
`timescale 1ns/1ns
module star_top;
  wire [7:0] empty_value, longer_value;
  empty_tail u_empty(empty_value);
  longer_tail u_longer(longer_value);
  initial #1 $display("empty=%0d longer=%0d", empty_value, longer_value);
endmodule

config star_config;
  design work.star_top;
  instance star_top.u_empty use starLib.empty_tail;
  instance star_top.u_longer use starLib.longer_tail;
endconfig

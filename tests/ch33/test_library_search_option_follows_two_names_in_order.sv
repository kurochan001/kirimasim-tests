/*
:name: test_library_search_option_follows_two_names_in_order
:description: Reversing two command-line library names reverses cell selection with the map order fixed
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.8.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: map_order_top
:expected_stdout: selected=17 supplemental=61
:files: libmap_order/red.map libmap_order/blue.map libmap_order/red/units.sv libmap_order/blue/units.sv libmap_order/probe.svh
*/

`timescale 1ns/1ns
module map_order_top;
  `include "probe.svh"
endmodule

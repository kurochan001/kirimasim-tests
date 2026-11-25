/*
:name: test_library_map_order_selects_first_matching_cell
:description: With two library maps and no config the first library supplying each cell wins
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.6.1 33.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: map_order_top
:expected_exit: 0
:expected_stdout: @test_library_map_order_selects_first_matching_cell.expected
:files: libmap_order/red.map libmap_order/blue.map libmap_order/red/units.sv libmap_order/blue/units.sv libmap_order/probe.svh
*/
`timescale 1ns/1ns
module map_order_top;
  `include "probe.svh"
endmodule

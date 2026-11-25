/*
:name: test_library_map_reversed_order_changes_selected_cell
:description: Reversing the map order changes the selected duplicate cell without reordering the source inputs
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.6.1 33.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: map_order_top
:expected_exit: 0
:expected_stdout: @test_library_map_reversed_order_changes_selected_cell.expected
:files: libmap_order/red.map libmap_order/blue.map libmap_order/red/units.sv libmap_order/blue/units.sv libmap_order/probe.svh
*/
`timescale 1ns/1ns
module map_order_top;
  `include "probe.svh"
endmodule

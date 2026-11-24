/*
:name: test_sdf_interconnect_overlaps_parent_and_child_loads
:description: Overlapping SDF interconnect annotations select the total delay for each hierarchical load subset
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.4 32.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_interconnect_overlaps_parent_and_child_loads.expected
*/
`timescale 1ns/1ns
module sdf_overlap_driver(input wire data, output wire driven);
  assign driven = data;
endmodule
module sdf_overlap_load(input wire data, output wire observed);
  assign observed = data;
endmodule
module sdf_overlap_branch(input wire data, output wire regular_out, special_out);
  sdf_overlap_load regular_load(data, regular_out);
  sdf_overlap_load special_load(data, special_out);
endmodule
module test_sdf_interconnect_overlaps_parent_and_child_loads;
  bit stimulus;
  wire net_data, outside_out;
  wire [1:0] regular_out, special_out;
  time source_edge, outside_edge;
  time branch_edge[2], regular_edge[2], special_edge[2];

  sdf_overlap_driver source(stimulus, net_data);
  sdf_overlap_branch branch(net_data, regular_out[0], special_out[0]);
  sdf_overlap_branch reversed(net_data, regular_out[1], special_out[1]);
  sdf_overlap_load outside_load(net_data, outside_out);
  always @(posedge source.driven) source_edge = $time;
  always @(posedge branch.data) branch_edge[0] = $time;
  always @(posedge reversed.data) branch_edge[1] = $time;
  for (genvar i = 0; i < 2; i++) begin : g_edges
    always @(posedge regular_out[i]) regular_edge[i] = $time;
    always @(posedge special_out[i]) special_edge[i] = $time;
  end
  always @(posedge outside_out) outside_edge = $time;

  initial begin
    int f;
    f = $fopen("overlap.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (DIVIDER .) (TIMESCALE 1ns)");
    $fdisplay(f, "(CELL (CELLTYPE \"%s\") (INSTANCE)",
              "test_sdf_interconnect_overlaps_parent_and_child_loads");
    $fdisplay(f, "(DELAY (ABSOLUTE");
    $fdisplay(f, "(INTERCONNECT source.driven branch.data (4))");
    $fdisplay(f, "(INTERCONNECT source.driven branch.special_load.data (9))");
    $fdisplay(f, "(INTERCONNECT source.driven reversed.special_load.data (9))");
    $fdisplay(f, "(INTERCONNECT source.driven reversed.data (4))");
    $fdisplay(f, "))))");
    $fclose(f);
    $sdf_annotate("overlap.sdf");
    #20 stimulus = 1;
    #20;
    $display("source=%0d outside=%0d", source_edge, outside_edge);
    $display("parent then child: branch=%0d regular=%0d special=%0d",
             branch_edge[0], regular_edge[0], special_edge[0]);
    $display("child then parent: branch=%0d regular=%0d special=%0d",
             branch_edge[1], regular_edge[1], special_edge[1]);
  end
endmodule

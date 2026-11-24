/*
:name: test_sdf_interconnect_down_hierarchy_includes_all_sources_above_the_source_port
:description: A downward SDF interconnect annotation includes every higher source that drives the ancestor port
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sdf_interconnect_down_hierarchy_includes_all_sources_above_the_source_port.expected
*/
`timescale 1ns/1ns
module sdf_down_driver(input wire enable, output wire driven);
  bufif1 (driven, 1'b1, enable);
endmodule
module sdf_down_load(input wire a, output wire observed);
  assign observed = a;
endmodule
module sdf_down_branch(inout wire entry, input wire local_enable, output wire loaded, direct);
  sdf_down_driver local_source(local_enable, entry);
  sdf_down_load delayed_input(entry, loaded);
  sdf_down_load direct_input(entry, direct);
endmodule
module test_sdf_interconnect_down_hierarchy_includes_all_sources_above_the_source_port;
  bit enable_a, enable_b, enable_local;
  wire carrier, loaded, direct;
  string source_times = "", loaded_times = "", direct_times = "";

  sdf_down_driver source_a(enable_a, carrier);
  sdf_down_driver source_b(enable_b, carrier);
  sdf_down_branch branch(carrier, enable_local, loaded, direct);
  always @(posedge branch.entry)
    source_times = {source_times, $sformatf(" %0d", $time)};
  always @(posedge loaded)
    loaded_times = {loaded_times, $sformatf(" %0d", $time)};
  always @(posedge direct)
    direct_times = {direct_times, $sformatf(" %0d", $time)};

  initial begin
    int f;
    f = $fopen("downward.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (DIVIDER .) (TIMESCALE 1ns)");
    $fdisplay(f, "(CELL (CELLTYPE \"%s\") (INSTANCE)",
              "test_sdf_interconnect_down_hierarchy_includes_all_sources_above_the_source_port");
    $fdisplay(f, "(DELAY (ABSOLUTE (INTERCONNECT branch.entry branch.delayed_input.a (5))))))");
    $fclose(f);
    $sdf_annotate("downward.sdf");
    #20 enable_a = 1;
    #20 enable_a = 0;
    #20 enable_b = 1;
    #20 enable_b = 0;
    #20 enable_local = 1;
    #20 enable_local = 0;
    #20 $display("source:%s load:%s direct:%s", source_times, loaded_times, direct_times);
  end
endmodule

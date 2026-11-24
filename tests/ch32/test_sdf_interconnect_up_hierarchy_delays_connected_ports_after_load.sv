/*
:name: test_sdf_interconnect_up_hierarchy_delays_connected_ports_after_load
:description: An upward SDF interconnect annotation delays every connected port after the ancestor load
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_interconnect_up_hierarchy_delays_connected_ports_after_load.expected
*/
`timescale 1ns/1ns
module sdf_up_driver(input wire a, output wire driven);
  assign driven = a;
endmodule
module sdf_up_load(input wire data, output wire observed);
  assign observed = data;
endmodule
module sdf_up_branch(input wire a, inout wire outgoing, output wire before_load);
  sdf_up_driver inner(a, outgoing);
  sdf_up_load local_observer(outgoing, before_load);
endmodule
module test_sdf_interconnect_up_hierarchy_delays_connected_ports_after_load;
  bit stimulus;
  wire outgoing, before_load, first_out, second_out;
  wire control_outgoing, control_before, control_after;
  time source_at, before_at, load_at, first_at, second_at, control_at;

  sdf_up_branch branch(stimulus, outgoing, before_load);
  sdf_up_load first(outgoing, first_out);
  sdf_up_load second(outgoing, second_out);
  sdf_up_branch control(stimulus, control_outgoing, control_before);
  sdf_up_load control_load(control_outgoing, control_after);
  always @(posedge branch.inner.driven) source_at = $time;
  always @(posedge before_load) before_at = $time;
  always @(posedge branch.outgoing) load_at = $time;
  always @(posedge first_out) first_at = $time;
  always @(posedge second_out) second_at = $time;
  always @(posedge control_after) control_at = $time;

  initial begin
    int f;
    f = $fopen("upward.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (DIVIDER .) (TIMESCALE 1ns)");
    $fdisplay(f, "(CELL (CELLTYPE \"%s\") (INSTANCE)",
              "test_sdf_interconnect_up_hierarchy_delays_connected_ports_after_load");
    $fdisplay(f, "(DELAY (ABSOLUTE (INTERCONNECT branch.inner.driven branch.outgoing (6))))))");
    $fclose(f);
    $sdf_annotate("upward.sdf");
    #20 stimulus = 1;
    #20 $display("source=%0d below=%0d ancestor=%0d above=%0d,%0d",
                 source_at, before_at, load_at, first_at, second_at);
    $display("unannotated=%0d", control_at);
  end
endmodule

/*
:name: test_vpi_force_release_whole_resolved_user_nettype
:description: A whole user-defined net can be forced and released through VPI, restoring the current resolved driver value
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 10.6.2 6.6.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @vpi_force_release_target.c
:expected_stdout: @test_vpi_force_release_whole_resolved_user_nettype.expected
*/
module test_vpi_force_release_whole_resolved_user_nettype;
  typedef bit [15:0] bus_value;
  function automatic bus_value sum_values(input bus_value drivers[]);
    bus_value total = 0;
    foreach (drivers[i]) total += drivers[i];
    return total;
  endfunction
  nettype bus_value summed_net with sum_values;

  bus_value drive_a = 16'h0044, drive_b = 16'h0011;
  summed_net vpi_net, procedural_net;
  assign vpi_net = drive_a;
  assign vpi_net = drive_b;
  assign procedural_net = drive_a;
  assign procedural_net = drive_b;

  initial begin
    #1;
    $display("initial vpi=%h sv=%h", vpi_net, procedural_net);
    $vt_force_target(vpi_net);
    force procedural_net = 16'h06a5;
    #1;
    $display("forced vpi=%h sv=%h", vpi_net, procedural_net);
    drive_a = 16'h00aa;
    drive_b = 16'h0011;
    #1;
    $display("drivers updated vpi=%h sv=%h", vpi_net, procedural_net);
    $vt_release_target(vpi_net);
    release procedural_net;
    $display("released vpi=%h sv=%h", vpi_net, procedural_net);
    #1;
    $display("settled vpi=%h sv=%h", vpi_net, procedural_net);
    drive_b = 16'h0007;
    #1;
    $display("new driver vpi=%h sv=%h", vpi_net, procedural_net);
  end
endmodule
